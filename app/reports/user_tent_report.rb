# Renders PDF "tent card" for one or more users
# If printed on card stock and folded down long axis, these card can be used as
# placards at meetings
# TODO: Implement logo interface to allow customization of logo used in cards
class UserTentReport < Prawn::Document
  attr_accessor :users, :brand

  def initialize(users=nil,brand=nil)
    self.users = users unless users.blank?
    self.brand = brand || Brand.first
    super( page_size: 'LETTER', page_layout: :landscape )
  end

  def to_pdf
    user = users.shift
    logo = brand.logo.tent.store_path
    rotate 180, origin: [720,306] do
      bounding_box [720,306], width: 720, height: 234 do
        image logo, height: 72
        move_down 9
        text user[0], size: 48, align: :center, style: :bold
        unless user[1].blank?
          text user[1], size: 36, align: :center, style: :italic
        end
      end
    end
    bounding_box [0,234], width: 720, height: 234 do
      image logo, height: 72
      move_down 9
      text user[0], size: 48, align: :center, style: :bold
      unless user[1].blank?
        text user[1], size: 36, align: :center, style: :italic
      end
    end
    unless users.empty?
      start_new_page
      to_pdf
    end
    render
  end
end

