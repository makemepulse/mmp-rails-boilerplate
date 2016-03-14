module ApplicationHelper

  def inline_svg(path)
    svg =  Rails.cache.fetch("svg_#{path}") do
      Rails.application.assets.find_asset(path + '.svg').to_s
    end
    raw svg
  end
end
