# name: discourse-affiliate
# about: Fork of the official affiliation plugin for Discourse
# version: 0.25
# authors: Régis Hanol (zogstrip), Sam Saffron, tkrunning
# url: https://github.com/tkrunning/discourse-affiliate

enabled_site_setting :affiliate_enabled

after_initialize do

  require File.expand_path(File.dirname(__FILE__) + '/lib/affiliate_processor')

  DiscourseEvent.on(:post_process_cooked) do |doc, post|
    doc.css('a[href]').each do |a|
      a['href'] = AffiliateProcessor.apply(a['href'])
    end
    true
  end

  # rename "affiliate_amazon_tag" site setting to "affiliate_amazon_com"
  if SiteSetting.where(name: "affiliate_amazon_tag").exists?
    SiteSetting.exec_sql("UPDATE site_settings SET name = 'affiliate_amazon_com' WHERE name = 'affiliate_amazon_tag'")
    SiteSetting.refresh!
  end

end
