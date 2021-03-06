// This is the main.js file. Import global CSS and scripts here.
// The Client API can be used here. Learn more: gridsome.org/docs/client-api

import DefaultLayout from '~/layouts/Default.vue'

import ApolloClient from 'apollo-boost'
import fetch from 'node-fetch'
import gql from 'graphql-tag'
import moment from 'moment-timezone'
import slugify from 'slugify'
import VueApollo from 'vue-apollo'
import VueMoment from 'vue-moment'
import { config, library } from '@fortawesome/fontawesome-svg-core'
import { faGithub } from '@fortawesome/free-brands-svg-icons'
import { faUser } from '@fortawesome/free-regular-svg-icons'
import { faCalendarDay, faExternalLinkAlt, faKey, faLockOpen, faMapMarker, faPlus } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import '@fortawesome/fontawesome-svg-core/styles.css'

const apolloClient = new ApolloClient({
  uri: 'https://postgraphile.' + process.env.GRIDSOME_STACK_DOMAIN + '/graphql',
  fetch,
  request: (operation) => {
    const jwt = localStorage.getItem('jwt')

    if (jwt) {
      operation.setContext({
        headers: {
          Authorization: `Bearer ${jwt}`
        }
      })
    }
  }
})

const apolloProvider = new VueApollo({
  defaultClient: apolloClient,
})

config.autoAddCss = false;
library.add(faCalendarDay, faExternalLinkAlt, faKey, faGithub, faLockOpen, faMapMarker, faPlus, faUser)

export default function (Vue, { appOptions, head }) {
  Vue.component('font-awesome', FontAwesomeIcon)

  // Set default layout as a global component
  Vue.component('Layout', DefaultLayout)

  Vue.use(VueApollo)
  Vue.use(VueMoment, {moment});

  Vue.prototype.$slugify = slugify

  appOptions.apolloProvider = apolloProvider
  head.htmlAttrs = {class: 'h-full'}
  head.bodyAttrs = {class: 'font-sans h-full text-white'}
  head.meta.push({
    name: 'viewport',
    content: 'width=device-width, initial-scale=1, shrink-to-fit=no'
  })

  apolloProvider.defaultClient.query({
    query: gql`query($username: String!, $password: String!) {
        authenticate(username: $username, password: $password)
    }`,
    variables: {
      username: '',
      password: ''
    },
  }).then((data) => {
    if (data.data.authenticate !== null) {
      localStorage.setItem('jwt', data.data.authenticate)
    }
  }).catch((error) => {
    console.error(error)
  })
}
