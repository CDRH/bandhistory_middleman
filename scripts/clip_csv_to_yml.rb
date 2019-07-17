require "csv"
require "yaml"

# combine a csv for all the metadata related to each clip
# with a csv for the reels (from archives records)
# into one mega reference file

csv_file = File.join(File.dirname(__FILE__), "../data/clips.csv")
reel_file = File.join(File.dirname(__FILE__), "../data/reels.csv")
yml_file = File.join(File.dirname(__FILE__), "../data/clips.yml")

clips = CSV.read(csv_file, headers: true)
reels = CSV.read(reel_file, headers: true)
# puts clips.headers

yml = {}

def decade(year_string)
  year = year_string[/(\d{4})/, 1] if year_string
  if year
    decade = year.to_i/10*10
    "decade-#{decade}"
  else
    "decade-unknown"
  end
end

def get_keyword_list(keywords)
  if keywords
    keywords
      .strip
      .split("; ")
      .map {|k| k.gsub(" ", "-")}
      .join(" ")
  end
end

def get_reel(reels, reel_id)
  reel = reels.select { |r| r["identifier/filename"] == reel_id }
  reel.first
end

clips.each do |clip|
  next if clip.header_row?
  id = clip["ID"]
  # TODO skipping reel 04 for now
  next if id == "04"
  reel_id = id[/^\d\.\d{2}/]
  archives_reel_id = clip["Archives Reel"]
  reel = get_reel(reels, archives_reel_id)

  keywords = get_keyword_list(clip["Keywords"])

  yml[id] = {
    "reel" => reel_id,
    "reel_time" => clip["Clip Seconds"],
    "year_estimate" => clip["Year Estimate"],
    "decade" => decade(clip["Year Estimate"]),
    "commons_link" => clip["Media Commons URL"],
    "thumbnail" => "#{reel_id}.jpeg",
    "desc" => clip["Short Description"],
    "keywords" => keywords,
    "archives_desc" => reel["description"],
    "archives_subj" => reel["subject"],
    "format" => reel["medium/format/type"],
    "record_group" => reel["source/RG#/MS#"],
    "archives_id" => archives_reel_id
  }
end

# sort by year and make sure "unknown" is at front
yml = Hash[
  yml.sort_by do |k,v|
    v["year_estimate"] == "Unknown" ? "0" : v["year_estimate"]
  end
]

File.open(yml_file, "w") {|f| f.write(yml.to_yaml) }
