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

  def test_lists_posts_with_links
    site = create_site
    create_post("2024-01-15-first-post.md", title: "First Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_match(/\[First Post\]\(.*first-post.*\)/, llms_page.content)
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
    assert_match(%r{\[Test Post\]\(/blog/.*test-post}, llms_page.content)
  end

  def test_works_without_baseurl
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_match(%r{\[Test Post\]\(/\d{4}/\d{2}/\d{2}/test-post/\)}, llms_page.content)
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

  def test_includes_post_date
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "Date: 2024-01-15"
  end

  def test_includes_post_description
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post", description: "A post about testing")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "A post about testing"
  end

  def test_omits_description_when_not_set
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    refute_includes llms_page.content, "  \n"
  end

  def test_includes_post_tags
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post", tags: ["ruby", "jekyll"])
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    assert_includes llms_page.content, "Tags: ruby, jekyll"
  end

  def test_omits_tags_when_not_set
    site = create_site
    create_post("2024-01-15-test-post.md", title: "Test Post")
    site.process

    llms_page = site.pages.find { |p| p.name == "llms.txt" }
    refute_includes llms_page.content, "Tags:"
  end

  def test_does_not_generate_full_by_default
    site = create_site
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert_nil full_page
  end

  def test_generates_full_when_configured
    site = create_site("llmstxt" => { "full" => true })
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert full_page, "llms-full.txt should be generated when configured"
  end

  def test_full_includes_site_header
    site = create_site("llmstxt" => { "full" => true }, "title" => "My Site")
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert_includes full_page.content, "# My Site"
  end

  def test_full_includes_post_content
    site = create_site("llmstxt" => { "full" => true })
    create_post("2024-01-15-test-post.md", title: "Test Post", content: "This is the full post content.")
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert_includes full_page.content, "## Test Post"
    assert_includes full_page.content, "This is the full post content."
  end

  def test_full_includes_post_metadata
    site = create_site("llmstxt" => { "full" => true })
    create_post("2024-01-15-test-post.md", title: "Test Post", tags: ["ruby", "jekyll"])
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert_includes full_page.content, "Date: 2024-01-15"
    assert_includes full_page.content, "Tags: ruby, jekyll"
  end

  def test_full_separates_posts_with_dividers
    site = create_site("llmstxt" => { "full" => true })
    create_post("2024-01-15-first-post.md", title: "First Post", content: "First content")
    create_post("2024-01-16-second-post.md", title: "Second Post", content: "Second content")
    site.process

    full_page = site.pages.find { |p| p.name == "llms-full.txt" }
    assert_includes full_page.content, "---"
  end
end
