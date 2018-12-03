require 'rails_helper'

describe AffiliateProcessor do

  def r(url)
    AffiliateProcessor.apply(url)
  end

  it 'can apply affiliate code to ldlc' do
    SiteSetting.affiliate_ldlc_com = 'samsshop'

    expect(r('http://www.ldlc.com/some_product?xyz=1')).to eq('http://www.ldlc.com/some_product?xyz=1#samsshop')
    expect(r('https://ldlc.com/some_product?xyz=1')).to eq('https://ldlc.com/some_product?xyz=1#samsshop')
  end

  it 'can apply affiliate code to flystein' do
    SiteSetting.affiliate_flystein = 'samsshop'

    expect(r('https://flystein.com/some_product')).to eq('https://flystein.com/some_product?af=samsshop')
  end

  it 'can change all types of urls correctly' do
    SiteSetting.affiliate_redirect_base_domain = 'https://nomadgate.com/go/'
    SiteSetting.affiliate_rewrite_domains = 'thomas.do,tkrunning,uri|n26.com,n26|transferwise.com,transferwise,url|nomadgate.com,nomadgate,uri|google.com,google,path|foobar.com,foobar'

    expect(r('https://n26.com')).to eq('https://nomadgate.com/go/n26')
    expect(r('https://transferwise.com/borderless')).to eq('https://nomadgate.com/go/transferwise?url=https://transferwise.com/borderless')
    expect(r('https://thomas.do/fancypants?hi=there&yo=man')).to eq('https://nomadgate.com/go/tkrunning?uri=/fancypants?hi=there&yo=man')
    expect(r('https://nomadgate.com/')).to eq('https://nomadgate.com/go/nomadgate')
    expect(r('https://nomadgate.com')).to eq('https://nomadgate.com/go/nomadgate')
    expect(r('https://google.com/')).to eq('https://nomadgate.com/go/google')
    expect(r('https://google.com')).to eq('https://nomadgate.com/go/google')
    expect(r('https://google.com/search?source=hp&ei=WX38WrfQM-rJ6ASwvq7QBg&q=yo')).to eq('https://nomadgate.com/go/google?path=/search')
    expect(r('https://foobar.com/')).to eq('https://nomadgate.com/go/foobar')
    expect(r('https://foobar.com')).to eq('https://nomadgate.com/go/foobar')
    expect(r('https://foobar.com?foo=bar')).to eq('https://nomadgate.com/go/foobar')
    expect(r('https://foobar.com/index.html')).to eq('https://nomadgate.com/go/foobar')
    expect(r('https://foobar.com/foobar?foo=bar')).to eq('https://foobar.com/foobar?foo=bar')
    expect(r('https://foobar.com/foobar.html?foo=bar')).to eq('https://foobar.com/foobar.html?foo=bar')
  end

  it 'can apply affiliate code correctly to amazon' do
    SiteSetting.affiliate_amazon_com = 'sams-shop'
    SiteSetting.affiliate_amazon_ca = 'ca-sams-shop'
    SiteSetting.affiliate_amazon_com_au = 'au-sams-shop'

    expect(r('https://www.amazon.com')).to eq('https://www.amazon.com?tag=sams-shop')
    expect(r('http://www.amazon.com/some_product?xyz=1')).to eq('http://www.amazon.com/some_product?tag=sams-shop')
    expect(r('https://www.amazon.com/some_product?xyz=1')).to eq('https://www.amazon.com/some_product?tag=sams-shop')
    expect(r('https://www.amazon.com?hello=1&tag=bobs-shop')).to eq('https://www.amazon.com?tag=sams-shop')
    expect(r('https://amzn.com/some_product?xyz=1')).to eq('https://amzn.com/some_product?tag=sams-shop')
    expect(r('https://smile.amazon.com/some_product?xyz=1')).to eq('https://smile.amazon.com/some_product?tag=sams-shop')
    expect(r('https://www.amazon.com.au/some_product?xyz=1')).to eq('https://www.amazon.com.au/some_product?tag=au-sams-shop')
    expect(r('https://www.amazon.ca/Dragon-Quest-Echoes-Elusive-Age-PlayStation/dp/B07BP3J6RG/ref=br_asw_pdt-5?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=&pf_rd_r=XFGPRSG0SVD5K3RKX5T3&pf_rd_t=36701&pf_rd_p=f8585743-c043-4665-80a7-0cc5fe97d596&pf_rd_i=desktop&th=1')).to eq('https://www.amazon.ca/Dragon-Quest-Echoes-Elusive-Age-PlayStation/dp/B07BP3J6RG/ref=br_asw_pdt-5?tag=ca-sams-shop')

    # keep node (BrowseNodeSearch) query parameter
    expect(r('https://www.amazon.com/b?ie=UTF8&node=13548845011')).to eq('https://www.amazon.com/b?tag=sams-shop&node=13548845011')
  end

  it 'can apply codes to post in post processor' do
    SiteSetting.queue_jobs = false
    SiteSetting.affiliate_amazon_com = 'sams-shop'

    post = create_post(raw: 'this is an www.amazon.com/link?testing yay')
    post.reload

    expect(post.cooked.scan('sams-shop').length).to eq(1)
  end

end
