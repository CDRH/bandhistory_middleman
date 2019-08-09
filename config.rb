# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

set :relative_links, true

activate :relative_assets
activate :directory_indexes

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

data.images.each do |category, category_contents|
  category_contents.each do |image|
    proxy "/multimedia/images/#{image["id"]}",
    "/multimedia/images/image_template.html",
    locals: { image: image, category: category }
  end
end

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

helpers do
  def tally_filter(data_hash, filter)
    tally = {}
    data_hash.each_value do |v|
      items = v[filter]
      if items
        items = items.split(" ")
        items.each do |item|
          if tally.key?(item)
            tally[item] += 1
          else
            tally[item] = 1
          end
        end
      end
    end
    tally.sort.to_h
  end
end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript
# end
