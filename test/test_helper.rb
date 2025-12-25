$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "jekyll"
require "jekyll-llmstxt"
require "fileutils"
require "tmpdir"

module JekyllTestHelper
  def create_site(config = {})
    @tmp_dir = Dir.mktmpdir("jekyll-llmstxt-test")
    @source_dir = File.join(@tmp_dir, "source")
    @dest_dir = File.join(@tmp_dir, "_site")

    FileUtils.mkdir_p(@source_dir)
    FileUtils.mkdir_p(File.join(@source_dir, "_posts"))

    default_config = {
      "source" => @source_dir,
      "destination" => @dest_dir,
      "title" => "Test Site",
      "description" => "A test site for jekyll-llmstxt",
      "permalink" => "pretty"
    }

    Jekyll::Site.new(Jekyll.configuration(default_config.merge(config)))
  end

  def create_post(filename, title: nil, content: "Post content")
    posts_dir = File.join(@source_dir, "_posts")
    front_matter = title ? "title: \"#{title}\"" : ""
    File.write(File.join(posts_dir, filename), <<~POST)
      ---
      layout: post
      #{front_matter}
      ---
      #{content}
    POST
  end

  def cleanup_site
    FileUtils.rm_rf(@tmp_dir) if @tmp_dir && File.exist?(@tmp_dir)
  end
end
