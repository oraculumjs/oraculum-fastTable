window.dependsMixins = (factory, mixin, mixins...) ->
  it "should depend on #{mixins}", ->
    mixinSettings = factory.mixinSettings[mixin]
    expect(mixinSettings.mixins).toContain mixin for mixin in mixins
