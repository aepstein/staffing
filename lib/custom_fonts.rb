module CustomFonts
  def include_palatino
    font_families.update(
      "Palatino" => { :bold => "#{::Rails.root}/db/fonts/PalatinoLTStd-Bold.ttf",
        :italic => "#{::Rails.root}/db/fonts/PalatinoLTStd-Italic.ttf",
        :bold_italic => "#{::Rails.root}/db/fonts/PalatinoLTStd-BoldItalic.ttf",
        :normal => "#{::Rails.root}/db/fonts/PalatinoLTStd-Roman.ttf" }
    )
  end
end

