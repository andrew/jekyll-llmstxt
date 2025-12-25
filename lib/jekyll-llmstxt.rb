require 'jekyll'

module Jekyll
  class LLMSGenerator < Generator
    safe true
    priority :low

    def generate(site)
      config = site.config["llmstxt"] || {}

      site.pages << create_llms_txt(site)

      if config["full"]
        site.pages << create_llms_full_txt(site)
      end
    end

    def site_header(site)
      content = site.config["title"] ? "# #{site.config["title"]}\n\n" : ""
      content += site.config["description"] ? "#{site.config["description"]}\n\n" : ""
      content
    end

    def create_llms_txt(site)
      Jekyll::PageWithoutAFile.new(site, site.source, "", "llms.txt").tap do |file|
        file.content = site_header(site)
        file.content += "## Posts:\n\n"

        site.posts.docs.each do |post|
          post_url = site.baseurl ? File.join(site.baseurl, post.url) : post.url
          title = post.data["title"] || File.basename(post.basename, ".*")
          file.content += "- [#{title}](#{post_url})\n"
          file.content += "  Date: #{post.date.strftime("%Y-%m-%d")}\n" if post.date
          file.content += "  #{post.data["description"]}\n" if post.data["description"]
          if post.data["tags"]&.any?
            file.content += "  Tags: #{post.data["tags"].join(", ")}\n"
          end
        end

        file.data["layout"] = nil
      end
    end

    def create_llms_full_txt(site)
      Jekyll::PageWithoutAFile.new(site, site.source, "", "llms-full.txt").tap do |file|
        file.content = site_header(site)

        site.posts.docs.each_with_index do |post, index|
          title = post.data["title"] || File.basename(post.basename, ".*")
          file.content += "## #{title}\n\n"
          file.content += "Date: #{post.date.strftime("%Y-%m-%d")}\n" if post.date
          if post.data["tags"]&.any?
            file.content += "Tags: #{post.data["tags"].join(", ")}\n"
          end
          file.content += "\n#{post.content}\n"
          file.content += "\n---\n\n" unless index == site.posts.docs.length - 1
        end

        file.data["layout"] = nil
      end
    end
  end
end