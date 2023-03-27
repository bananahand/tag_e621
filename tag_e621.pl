#!/usr/bin/perl

# Add tags from e621.net to local image EXIF metadata.
#
# $post_csv = posts db dump from https://e621.net/db_export/
# $file_path = path containing images downloaded from e621.net
#
# Authors
# uwubanana@e621.net
# kora viridian@e621.net
#
# 2023-03-26

#### CHANGE THESE VARIABLES

my $posts_csv = "posts-2023-03-26.csv";
my $file_path = "files/e621_images/";

#### DO NOT CHANGE BELOW THIS LINE

use Text::CSV_XS;
use Path::Class;
use File::Basename;
use Image::ExifTool;

print "Parsing " . $posts_csv . "...\n";
binmode STDOUT, ":utf8";
my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });
open my $fh, "<", "$posts_csv" or die "$posts_csv $!";
$junk = <$fh>;

while (my $row = $csv->getline ($fh))
  {
  $tags{@$row[3]} = @$row[8];
  }
close $fh or die "$posts_txt: $!";

print "Searching: " . $file_path . "...\n";
my @files;
dir($file_path)->recurse(callback => sub {
  my $file = shift;
  if($file =~ /(\.jpg|\.png|\.gif|\.swf|\.webm)\z/) {
    push @files, $file->absolute->stringify;
  }
});

print "Tagging files...\n";
for my $file (@files) {
  print "Tagging: " . $file . "\n";
  my $base_file_name = basename($file);
  (my $file_md5 = $base_file_name) =~ s/\.[^.]+$//;
  (my $formatted_tags = $tags{$file_md5}) =~ s/\ /,/g;
  my $exifTool = Image::ExifTool->new;
  $exifTool->Options(IgnoreMinorErrors => '1');
  $exifTool->SetNewValue(Keywords => "$formatted_tags");
  $exifTool->SetNewValue(Subject => "$formatted_tags");
  $exifTool->SetNewValue(LastKeywordIPTC => "$formatted_tags");
  $exifTool->SetNewValue(LastKeywordXMP => "$formatted_tags");
  $exifTool->WriteInfo($file);
}

print "Done!\n"
