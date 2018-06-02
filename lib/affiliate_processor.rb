# frozen_string_literal: true
#
class AffiliateProcessor
  def self.create_amazon_rule(domain)
    lambda do |url, uri|
      code = SiteSetting.send("affiliate_amazon_#{domain.gsub('.', '_')}")
      if code.present?
        original_query_array = URI.decode_www_form(String(uri.query)).to_h
        query_array = [["tag", code]]
        query_array << ['node', original_query_array['node']] if original_query_array['node'].present?
        uri.query = URI.encode_www_form(query_array)
        uri.to_s
      else
        url
      end
    end
  end

  def self.rules
    #return @rules if @rules
    postfixes = %w{
      com com.au com.br com.mx
      ca cn co.jp co.uk de
      es fr in it nl
    }

    rules = {}

    postfixes.map do |postfix|
      rule = create_amazon_rule(postfix)

      rules["amzn.com"] = rule if postfix == 'com'
      rules["www.amazon.#{postfix}"] = rule
      rules["smile.amazon.#{postfix}"] = rule
      rules["amazon.#{postfix}"] = rule
    end

    rule = lambda do |url, uri|
      code = SiteSetting.affiliate_ldlc_com
      if code.present?
        uri.fragment = code
        uri.to_s
      else
        url
      end
    end

    rules['www.ldlc.com'] = rule
    rules['ldlc.com'] = rule

    rule = lambda do |url, uri|
      code = SiteSetting.affiliate_flystein
      if code.present?
        query_array = [["af", code]]
        uri.query = URI.encode_www_form(query_array)
        uri.to_s
      else
        url
      end
    end

    rules['flystein.com'] = rule
    rules['www.flystein.com'] = rule

    domain_rules = SiteSetting.affiliate_rewrite_domains
    domain_rules.split('|').each do |domain_rule|
      domain_name = domain_rule.split(',')[0]
      rule = lambda do |url, uri|
        slug = domain_rule.split(',')[1]
        should_rewrite = true
        if domain_rule.split(',')[2] == 'url'
          slug = slug + '?url=' + url
        elsif domain_rule.split(',')[2] == 'uri'
          if URI(url).request_uri != '/'
            slug = slug + '?uri=' + URI(url).request_uri
          end
        elsif domain_rule.split(',')[2] == 'path'
          if URI(url).path != '/' && URI(url).path != ''
            slug = slug + '?path=' + URI(url).path
          end
        else
          if URI(url).path != '/' && URI(url).path != '' && URI(url).path != '/index.html' && URI(url).path != '/index.htm'
            should_rewrite = false
          end
        end
        base = SiteSetting.affiliate_redirect_base_domain
        if base.present? && should_rewrite == true
          uri = base + slug
          uri.to_s
        else
          url
        end
      end

      rules[domain_name] = rule
    end

    @rules = rules
  end

  def self.apply(url)
    uri = URI.parse(url)

    if uri.scheme == 'http' || uri.scheme == 'https'
      rule = rules[uri.host]
      return rule.call(url, uri) if rule
    end

    url
  rescue
    url
  end

end