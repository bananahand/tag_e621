# tag_e621
A small bash script to embed tags from e621.net into image EXIF metadata.

Prerequisites:

`jq` https://stedolan.github.io/jq/

`exiftool` https://exiftool.org/install.html

`mlr` https://github.com/johnkerl/miller

How to use:

1) Download images from e621.net to some directory, for example /home/uwubanana/e621_files/
2) Download a posts db dump from https://e621.net/db_export/
3) Update "posts_export" and "file_path" to the db dump and your e621 images.
4) Make the script executable: `chmod +x tag_e621.sh`
5) Run the script: `./tag_e621.sh`
