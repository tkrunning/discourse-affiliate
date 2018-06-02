## discourse-affiliate

Fork of the official affiliation plugin for Discourse. This fork adds support for defining any domain you'd like as being redirected.

## Usage

Go to /admin/site_settings/category/plugins, enter your affiliation ids and enable the plugin via the `affiliate_enabled` site setting.


### Defining custom domains
To define cusom domains to rewrite the links for, do as follows:

- First define your base domain, which is where you host your "redirection logic". You could host it yourself, and account for `url`, `uri` and `path` variables (best—could support deep-linking) or use a link shortener service like Geni.us (will allow you to update links in the future, run A/B tests, add tracking pixels, etc—cheap, starts at $2 per month) or Bit.ly (free, but you can't update links in the future, run tests, etc). This could be `https://foo.com/out/` (remember the trailing slash)
- You can define three variables for each custom domain you want to rewrite the links for: the domain itself (e.g. `bar.com`), the path to add to your base redirection domain (e.g. `bar`), and optionally if you'd like you can add a variable that will pass the original URL in whole or in part (e.g. `uri`). In this example, you would write `bar.com,bar,uri`

Note that `bar.com` is not the same as `www.bar.com`, so you'll have to add an entry for each subdomain you want to support.

#### The difference between `url`, `uri` and `path`
with `bar.com,bar,url`:

- `https://bar.com` --> `https://foo.com/out/bar?url=https://bar.com`
- `https://bar.com/search?q=something` --> `https://foo.com/out/bar?url=https://bar.com/search?q=something`

with `bar.com,bar,uri`:

- `https://bar.com` --> `https://foo.com/out/bar`
- `https://bar.com/search?q=something` --> `https://foo.com/out/bar?uri=/search?q=something`

with `bar.com,bar,path`:

- `https://bar.com` --> `https://foo.com/out/bar`
- `https://bar.com/search?q=something` --> `https://foo.com/out/bar?path=/search`

with only `bar.com,bar`:

- `https://bar.com` --> `https://foo.com/out/bar`
- `https://bar.com/?q=something` --> `https://foo.com/out/bar`
- `https://bar.com/search?q=something` --> `https://bar.com/search?q=something`

## Installation

Follow our [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157) howto, using
`git clone https://github.com/tkrunning/discourse-affiliate.git` as the plugin command.

## Issues

If you have issues or suggestions for the plugin, please bring them up on [Discourse Meta](https://meta.discourse.org).

## License

MIT
