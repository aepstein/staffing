class UserTentReport < Prawn::Document
  attr_accessor :user

  def initialize(user=nil)
    self.user = user unless user.nil?
    super( :page_size => 'LETTER', :page_layout => :landscape )
  end

  def to_pdf
    rotate 180, :origin => [720,306] do
      bounding_box [720,306], :width => 720, :height => 234 do
        image "#{::Rails.root}/public/images/layout/tent/logo.png", :height => 72
        text self.user.name, :size => 48, :align => :center
      end
    end
    bounding_box [0,234], :width => 720, :height => 234 do
      image "#{::Rails.root}/public/images/layout/tent/logo.png", :height => 72
      text self.user.name, :size => 48, :align => :center
    end
    render
  end
end

