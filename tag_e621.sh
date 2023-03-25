#!/usr/bin/env bash

#### Change these variables.

# Get the posts export from https://e621.net/db_export/
posts_export="posts-2023-03-23.csv"
# Path containing images from e621.net
file_path="files/e621_popular/2007"

#### Only change these if you know what you're doing.

# Path to temporary file of trimmed json. Managed by script.
tags_json="/tmp/tags.json"
# Path to temporary file of posts csv converted to json. Managed by script.
posts_json="/tmp/$(echo ${posts_export} | awk -F'.' '{print $1}').json"

#### DONT CHANGE BELOW THIS LINE!

# Convert csv to json
if [[ ! -f ${posts_json} ]]
then
  echo "Converting ${posts_export} to json..."
  mlr --c2j --jlistwrap cat ${posts_export} > ${posts_json}
else
  echo "${posts_json} already exists! Remake? (y/n)"
  read delete_posts_json
  if [[ "$delete_posts_json" = "y" ]]
  then
    rm -f ${posts_json}
    echo "Converting ${posts_export} to json..."
    mlr --c2j --jlistwrap cat ${posts_export} > ${posts_json}
  fi
fi

# These posts have descriptions with special control characters that bug jq out.
# Replaces description with "bugged" to fix; descriptions are not needed.
echo "Delete bugged posts? You should do this the first time the json is generated! (y/n)"
read delete_bugs
if [[ "$delete_bugs" = "y" ]]
then
  echo "Fixing bugged posts..."
  sed -i '51675842s/^.*$/  \"description\": \"bugged\",/' ${posts_json}
  sed -i '100044863s/^.*$/  \"description\": \"bugged\",/' ${posts_json}
fi

# Trim posts_json stripping everything but md5 + tags for fast match with grep.
if [[ ! -f ${tags_json} ]]
then
  echo "Trimming $(echo ${posts_export} | awk -F'.' '{print $1}').json..."
  jq -c ".[] | {"md5":.md5, "tags":[.tag_string]}" <${posts_json} >${tags_json}
else
  echo "${tags_json} already exists! Remake? (y/n)"
  read delete_tags_json
  if [[ "$delete_tags_json" = "y" ]]
  then
    rm -f ${tags_json}
    echo "Trimming $(echo ${posts_export} | awk -F'.' '{print $1}').json..."
    jq -c ".[] | {"md5":.md5, "tags":[.tag_string]}" <${posts_json} >${tags_json}
  fi
fi

# Build array of files to tag.
echo "Finding images to tag..."
while IFS= read -rd '' files
do
  file_array+=("$files")
done < <(find ${file_path} -type f -print0)

# Use exiftool to update image metadata with tag list.
# This script keeps the same behavior as if you were manually adding tags through windows file properties.
# Tags are added to the following tag fields: Keywords, Subject, LastKeywordIPTC and LastKeywordXMP.
# Most images have tags that go beyond the IPTC limits so tags will show as truncated in windows file properties.
# Even though tags show as truncated they all still work. You can view full tags through "exiftool <file>" if needed.
echo "Tagging images..."
for (( i = 0; i < ${#file_array[@]}; i=i+1 ))
do
  md5="$(echo ${file_array[$i]} | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}')"
  ext="$(echo ${file_array[$i]} | awk -F'/' '{print $NF}' | awk -F'.' '{print $2}')"
  tags="$(grep -m1 "${md5}" ${tags_json} | jq -r ".tags[]" | sed -e "s/ /,/g")"
  if [[ ! "${ext}" == @(swf|webm) ]]
  then
    echo "Tagging ${file_array[$i]}"
    exiftool -m -q -overwrite_original -Keywords=${tags} -Subject=${tags} -LastKeywordIPTC=${tags} -LastKeywordXMP=${tags} ${file_array[$i]}
  else
    echo "Unsupported file detected: ${file_array[$i]} Skipping..."
  fi
done

# Delete temporary files.
echo "Tagging complete! Delete temp files? (y/n)"
read delete_temp
if [[ "$delete_temp" = "y" ]]
then
  echo "Cleaning up..."
  rm -f ${posts_json}
  rm -f ${tags_json}
else
  echo "Done!"
fi
