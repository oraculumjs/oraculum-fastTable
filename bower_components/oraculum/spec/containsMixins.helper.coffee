window.containsMixins = (definition, mixins...) ->
  it "should include #{mixins}", ->
    expect(definition.options.mixins).toContain mixin for mixin in mixins
