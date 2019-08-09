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

collection_csvs = {
  "band" => CSV.read(File.join(csv_dir, "rg130815.csv"), headers: true),
  "lentz" => CSV.read(File.join(csv_dir, "2029-lentz.csv"), headers: true),
  "johnson" => CSV.read(File.join(csv_dir, "johnson.csv"), headers: true),
  "snider" => CSV.read(File.join(csv_dir, "rg130833.csv"), headers: true),
  "ucomm" => CSV.read(File.join(csv_dir, "ucomm-band-digitized.csv"), headers: true),
  # this csv is cobbled together for the baseball, football, etc where I
  # have one image but no spreadsheet from archives
  "other" => CSV.read(File.join(csv_dir, "other-collections-partial.csv"), headers: true)
}

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

def guess_year(date)
  year = "Unknown"
  if date
    # many in MM/DD/YY format, if so assume 1900s
    if date[/\d{1,2}\/\d{1,2}\/(\d{2})/,1]
      partial = date[/\d{1,2}\/\d{1,2}\/(\d{2})/,1]
      year = "19#{partial}"
    # check for MM/DD/YYYY and M/D/YYYY
    elsif date[/\d{1,2}\/\d{1,2}\/(\d{4})/,1]
      year = date[/\d{1,2}\/\d{1,2}\/(\d{4})/,1]
    # check for anything starting with 4 digits, assuming that's a year
    # even if it's YYYY? or YYYY-YYYY, YYYY March 3, etc
    elsif date[/^(\d{4})/,1]
      year = date[/(^\d{4})/,1]
    end
  end
  # converting it to a string to make it easier to sort again "Unknown"
  year.to_s
end

categorized.each do |image|
  metadata = nil
  collection = nil
  # search through the metadata spreadsheets looking for a match
  # and report as no_metadata if there's a problem
  collection_csvs.each do |collection_name, sheet|
    sheet.each do |row|
      # remove file endings
      if image["filename"] == row["identifier/filename"]
        metadata = row
        collection = collection_name
        break
      end
    end
  end
  if !metadata
    no_metadata << image["filename"]
    add_to_category(image["category"], {
      "id" => image["filename"],
      "year" => image["patch_date"] || "Undated",
      "date" => image["patch_date"] || "Undated",
      "title" => image["patch_title"] || "Unlabeled",
      "description" => image["patch_description"] || "No Description",
      "creator" => "Unknown",
      "collection" => collection || "Unknown collection"
    })
  else
    year = guess_year(image["patch_date"] || metadata["date"])

    add_to_category(image["category"], {
      "id" => image["filename"],
      "title" => image["patch_title"] || metadata["title"],
      "date" => image["page_date"] || metadata["date"],
      "year" => year,
      "description" => image["patch_description"] || metadata["description"],
      "creator" => metadata["creator/photographer"],
      "box" => metadata["tablecontents/boxes/folders"],
      "collection" => metadata["isPartOf/Collection"],
      "rg" => metadata["source/RG#/MS#"],
      "rights" => metadata["rights"],
      "publisher" => metadata["publisher/repository"]
    })
  end
end

@categories.each do |key, values|
  @categories[key] = values.sort_by do |item|
    item["year"] == "Unknown" ? "0" : item["year"]
  end
end

File.open(yml_out, "w") { |f| f.write(@categories.to_yaml) }

puts "the following images do not have metadata!"
puts no_metadata
puts no_metadata.length
