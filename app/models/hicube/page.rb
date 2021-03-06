module Hicube
  class Page
  
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Slug

    # Slugs
    slug              :title, scope: :account_id

    # Associations
    belongs_to :account, class_name: 'Hicube::Account'
    has_many :children, class_name: 'Hicube::Page'
    belongs_to :parent, class_name: 'Hicube::Page'
    embeds_many :content, class_name: 'Hicube::Content'
    
    accepts_nested_attributes_for :content, allow_destroy: true

    # Page cannot be parent to itself
    before_save do |page|
      unless page.parent.nil? || page.parent.blank?
        return false if page.parent == page
      end
    end

    # Callback to see if trying to delete index page
    before_destroy do |page|
      if page.junction?
        errors[:base] << "Cannot delete page with child pages, delete children first."
        return false
      elsif page.index?
        errors[:base] << "Cannot delete Index page."
        return false
      end
    end

    field :tt, type: String,
      as:             :title

    field :bd, type: String,
      as:             :body

    # appear in header
    field :hd, type: Boolean, 
      as:             :header,
      default:        true

    # appear in footer
    field :ft, type: Boolean, 
      as:             :footer,
      default:        true

    # Order for links
    field :od, type: Integer,
      as:             :order,
      default:        10

    # field :jt, type: Boolean, # Saving as String, so don't have to do transalation from String to Boolean in controller
    #   as:             :junction,
    #   default:        false

    # SEO settings
    field :st, type: String,
      as:             :seo_title

    field :sk, type: String,
      as:             :seo_keywords

    field :sd, type: String,
      as:             :seo_description

    # Validations
    validates_presence_of :title, :header, :footer, :order
    validates_uniqueness_of :title, scope: [:parent, :account]

    #
    # Scopes
    #
    default_scope -> { ne(_slugs: ["index"]) }
    scope :parents, -> { where(parent: nil).asc(:order) }
    scope :headers, -> { where(header: true).asc(:order) }
    scope :footers, -> { where(footer: true).asc(:order) }
    # scope :children, -> (parent) {where(parent: parent)}

    def to_s
      self.title
    end

    def index?
      slug.eql?('index')
    end

    def child?
      !self.parent.nil? and self.parent.present?
    end

    def junction?
      !(self.children.nil? or self.children.empty?)
    end

    def head
      self.content.where(head: true)
    end
  end
end
