window.createTestbed = ->
  testbed = document.createElement 'div'
  testbed.id = 'testbed'
  document.body?.appendChild testbed
  return testbed

window.removeTestbed = ->
  testbed = document.getElementById 'testbed'
  document.body?.removeChild testbed
