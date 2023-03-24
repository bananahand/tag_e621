# tag_e621
A small bash script to embed tags from e621.net into image EXIF metadata.

Prerequisites:

`jq` https://stedolan.github.io/jq/

`exiftool` https://exiftool.org/install.html

`mlr` https://github.com/johnkerl/miller

How to use:

1) Download images from e621.net to some directory, for example /home/uwubanana/e621_files/
2) Download a posts db dump from https://e621.net/db_export/
3) Update "posts_export" and "file_path" variables to the db dump and your e621 images.
4) Make the script executable: `chmod +x tag_e621.sh`
5) Run the script: `./tag_e621.sh`

On the first run it will convert the posts csv to json, then trim that json to create objects as {md5, [tags]} for easy lookup with grep. It also cleans some post descriptions containing bad characters that break the json processor. These first run steps take about 5 minutes to complete before the tagging starts. I've added logic to detect if these temporary files have already been generated so you can skip to speed up the time it takes for tagging to start.

From my tests on a machine with a spinning HDD the script tags 1 image every ~300ms which slightly over 3 per second. If your images are on an NVMe SSD I would expect tagging to be even faster.

Notes: 

1) exiftool doesn't support writing to swf or webm so these files will be skipped.
2) This script keeps the same behavior as if you were manually adding tags through Windows file properties.
3) Tags are added to the following tag fields: Keywords, Subject, LastKeywordIPTC and LastKeywordXMP.
4) Most images have tags that go beyond the IPTC limits so tags will show as truncated in Windows file properties.
5) Even though tags show as truncated they all still work. You can view full tags through "exiftool \<file\>" if needed.
