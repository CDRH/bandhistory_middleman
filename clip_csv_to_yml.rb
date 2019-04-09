require "csv"
require "yaml"

csv_file = "data/clips.csv"
yml_file = "data/clips.yml"

clips = CSV.read(csv_file, headers: true)
# puts clips.headers

yml = {}

def get_keyword_list(keywords)
  if keywords
    keywords
      .strip
      .split("; ")
      .map {|k| k.gsub(" ", "-")}
      .join(" ")
  end
end

clips.each do |clip|
  next if clip.header_row?
  id = clip["ID"]
  reel = id[/^\d\.\d{2}/]
  keywords = get_keyword_list(clip["Keywords"])
  yml[id] = {
    "reel" => reel,
    "reel_time" => clip["Clip Seconds"],
    "year_estimate" => clip["Year Estimate"],
    "commons_link" => clip["Media Commons URL"],
    "thumbnail" => "#{reel}.jpeg",  # TODO
    "video" => "TODO",
    "desc" => clip["Short Description"],
    "keywords" => keywords
  }
end

File.open(yml_file, "w") {|f| f.write(yml.to_yaml) }
