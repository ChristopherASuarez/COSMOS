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
  <div>
    <top-bar :title="title" />
    <v-card>
      <v-tabs v-model="curTab" fixed-tabs>
        <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
          {{ tab.displayName }}
        </v-tab>
      </v-tabs>
      <router-view />
    </v-card>
  </div>
</template>

<script>
import TopBar from '@cosmosc2/tool-common/src/components/TopBar'
import { TabsList } from './tabs'

export default {
  components: {
    TopBar,
  },
  data() {
    return {
      title: 'COSMOS Administrator Console',
      curTab: null,
      tabs: TabsList,
    }
  },
  methods: {},
}
</script>
