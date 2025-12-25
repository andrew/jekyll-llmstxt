require 'jekyll'

module Jekyll
  class LLMSGenerator < Generator
    safe true
    priority :low

    def generate(site)
      # Create llms.txt file at site root
      site.pages << Jekyll::PageWithoutAFile.new(site, site.source, "", "llms.txt").tap do |file|
        file.content = site.config["title"] ? "# #{site.config["title"]}\n\n" : ""
        file.content += site.config["description"] ? "#{site.config["description"]}\n\n" : ""
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
  end
end