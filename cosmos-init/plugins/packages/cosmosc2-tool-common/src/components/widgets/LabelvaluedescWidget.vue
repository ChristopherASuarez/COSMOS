<!--
# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder
-->

<template>
  <div ref="container" class="d-flex flex-row">
    <label-widget
      :parameters="labelName"
      :settings="settings"
      :style="computedStyle"
      :widgetIndex="0"
    />
    <value-widget
      :parameters="parameters.slice(0, 3)"
      :settings="settings"
      :style="computedStyle"
      :widgetIndex="1"
    />
  </div>
</template>

<script>
import Widget from './Widget'
import LabelWidget from './LabelWidget.vue'
import ValueWidget from './ValueWidget.vue'
import { CosmosApi } from '../../services/cosmos-api.js'

export default {
  mixins: [Widget],
  data() {
    return {
      description: '',
    }
  },
  components: {
    LabelWidget,
    ValueWidget,
  },
  computed: {
    labelName() {
      return [this.description]
    },
  },
  created() {
    if (this.parameters.length > 3) {
      this.description = this.parameters[3]
    } else {
      this.api = new CosmosApi()
      this.api
        .get_item(this.parameters[0], this.parameters[1], this.parameters[2])
        .then((details) => {
          this.description = details['description']
        })
    }
  },
}
</script>
