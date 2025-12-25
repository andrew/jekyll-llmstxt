require "test_helper"

class LLMSGeneratorTest < Minitest::Test
  include JekyllTestHelper

  def teardown
    cleanup_site
  end

  def test_generates_llms_txt_page
    site = create_site
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert llms_page, "llms.txt page should be generated"
  end

  def test_includes_site_title
    site = create_site("title" => "My Blog")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "# My Blog"
  end

  def test_includes_site_description
    site = create_site("description" => "A great blog about things")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "A great blog about things"
  end

  def test_omits_title_when_not_configured
    site = create_site("title" => nil)
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    refute_match(/^# /, llms_page.content)
  end

  def test_omits_description_when_not_configured
    site = create_site("title" => "Test", "description" => nil)
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    lines = llms_page.content.lines
    assert_equal "# Test\n", lines[0]
    assert_equal "\n", lines[1]
    assert_equal "## Posts:\n", lines[2]
  end

  def test_includes_posts_section
    site = create_site
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "## Posts:"
  end

  def test_lists_posts_with_markdown_links
    site = create_site
    create_post("2024-01-15-first-post.md", title: "First Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_match(/\[First Post\]\(.*index\.md\)/, llms_page.content)
  end

  def test_lists_multiple_posts
    site = create_site
    create_post("2024-01-15-first-post.md", title: "First Post")
    create_post("2024-01-16-second-post.md", title: "Second Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "[First Post]"
    assert_includes llms_page.content, "[Second Post]"
  end

  def test_prepends_baseurl_to_post_links
    site = create_site("baseurl" => "/blog")
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_match(%r{\[Test Post\]\(/blog/.*index\.md\)}, llms_page.content)
  end

  def test_works_without_baseurl
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_match(%r{\[Test Post\]\(/\d{4}/\d{2}/\d{2}/test-post/index\.md\)}, llms_page.content)
  end

  def test_page_has_no_layout
    site = create_site
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_nil llms_page.data["layout"]
  end

  def test_works_with_no_posts
    site = create_site
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert llms_page
    assert_includes llms_page.content, "## Posts:"
  end

  def test_uses_filename_when_post_has_no_title
    site = create_site
    create_post("2024-01-15-my-post.md")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "[My Post]"
  end
end
