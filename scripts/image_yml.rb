require "csv"
require "yaml"

# this file pulls together all the image metadata csvs
# which come from archives digitization records, primarily
# and creates a mega reference file for the images

@categories = {
  "aerial" => [],
  "documents" => [],
  "group" => [],
  "parade" => [],
  "people" => [],
  "other" => [],
}

no_metadata = []

csv_dir = File.join(File.dirname(__FILE__), "../data/image_metadata")

yml_out = File.join(File.dirname(__FILE__), "../data/images.yml")

categorized = CSV.read(File.join(csv_dir, "categories.csv"), headers: true)
lentz = CSV.read(File.join(csv_dir, "2029-lentz.csv"), headers: true)
snider = CSV.read(File.join(csv_dir, "rg130833.csv"), headers: true)
ucomm = CSV.read(File.join(csv_dir, "ucomm-band-digitized.csv"), headers: true)
# this csv is cobbled together for the baseball, football, etc where I
# have one image but no spreadsheet from archives
other = CSV.read(File.join(csv_dir, "other-collections-partial.csv"), headers: true)

# categories should have every images that will need this metadata business
# so use that as the authoritative list of images, and organize
# them into said categories

def add_to_category(category, info)
  if @categories.key?(category)
    @categories[category] << info
  else
    @categories["other"] << info
  end
end

categorized.each do |image|
  metadata = nil
  # search through the metadata spreadsheets looking for a match
  # and report as no_metadata if there's a problem
  [lentz, snider, ucomm].each do |sheet|
    sheet.each do |row|
      # remove file endings
      if image["filename"] == row["identifier/filename"]
        metadata = row
        break
      end
    end
  end
  if !metadata
    no_metadata << image["filename"]
    add_to_category(image["category"], { "id" => image["filename"] })
  else
    add_to_category(image["category"], {
      "id" => image["filename"],
      "title" => metadata["title"],
      "description" => metadata["description"],
      "date" => metadata["date"],
      "box" => metadata["tablecontents/boxes/folders"],
      "collection" => metadata["publisher/repository"],
      "rg" => metadata["source/RG#/MS#"]
    })
  end
end

File.open(yml_out, "w") { |f| f.write(@categories.to_yaml) }

puts "the following images do not have metadata!"
puts no_metadata
puts no_metadata.length
