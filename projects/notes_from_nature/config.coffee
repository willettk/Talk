socialDefaults =
  href: 'http://talk.notesfromnature.org/'
  title: 'Notes From Nature'
  summary: 'Some summary line'
  image: 'http://example.com/image.jpg'
  twitterTags: 'via @notes_from_nature'

Config =
  test:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: null
    classifyUrl: null
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentLocal:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'http://localhost:3000'
    classifyUrl: 'http://localhost:9294/#/archives'
    socialDefaults: socialDefaults
    analytics: { }
  
  developmentRemote:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'https://dev.zooniverse.org'
    classifyUrl: 'http://www.notesfromnature.org/beta/#/archives'
    socialDefaults: socialDefaults
    analytics: { }
  
  production:
    project: 'notes_from_nature'
    projectName: 'Notes From Nature'
    prefix: 'NN'
    apiHost: 'https://api.zooniverse.org'
    classifyUrl: 'http://www.notesfromnature.org/beta/#/archives'
    socialDefaults: socialDefaults
    analytics:
      account: 'UA-1234567-89'
      domain: 'http://talk.notesfromnature.org'

env = if window.jasmine
  'test'
else if window.location.port is '9295'
  'developmentLocal'
else if window.location.port > 1024 
  'developmentRemote'
else
  'production'

module.exports = Config[env]
