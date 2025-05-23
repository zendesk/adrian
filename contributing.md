## Contributing

- Fork it
- Create your feature branch (`git checkout -b my-new-feature`)
- Commit your changes (`git commit -am 'Added some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Include specs, make sure are green.

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. run `bundle lock` to update `Gemfile.lock`,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/adrian/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/adrian/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.
