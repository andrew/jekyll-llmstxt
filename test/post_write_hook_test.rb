require "test_helper"

class PostWriteHookTest < Minitest::Test
  include JekyllTestHelper

  def teardown
    cleanup_site
  end

  def test_copies_post_markdown_to_output
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post", content: "Hello world")
    site.process

    post = site.posts.docs.first
    copied_file = File.join(@dest_dir, post.url, "index.md")

    assert File.exist?(copied_file), "Markdown file should be copied to output"
  end

  def test_copied_file_matches_source_content
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post", content: "Original markdown content")
    site.process

    post = site.posts.docs.first
    copied_file = File.join(@dest_dir, post.url, "index.md")
    source_file = post.path

    assert_equal File.read(source_file), File.read(copied_file)
  end

  def test_copies_multiple_posts
    site = create_site
    create_post("2024-01-15-first-post.md", title: "First", content: "First content")
    create_post("2024-01-16-second-post.md", title: "Second", content: "Second content")
    site.process

    site.posts.docs.each do |post|
      copied_file = File.join(@dest_dir, post.url, "index.md")
      assert File.exist?(copied_file), "#{post.data['title']} markdown should be copied"
    end
  end

  def test_works_with_no_posts
    site = create_site
    site.process

    assert Dir.exist?(@dest_dir)
  end
end
