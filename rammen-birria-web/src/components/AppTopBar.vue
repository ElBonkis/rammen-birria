<script setup lang="ts">
import { computed } from "vue";
import { useRoute, useRouter, RouterLink } from "vue-router";
import CategoryFilterBar from "@/components/CategoryFilterBar.vue";

import { isAuthenticated, logout } from "@/api/http";

const props = defineProps<{
  showCategoryFilter?: boolean;
  categoryId?: number | null;
}>();

const emit = defineEmits<{
  (e: "update:category-id", v: number | null): void;
}>();

const route = useRoute();
const router = useRouter();

const showFilter = computed(() => !!props.showCategoryFilter);

function goLogin() {
  const redirect = route.fullPath || "/products";
  router.push({ name: "login", query: { redirect } });
}

async function doLogout() {
  await logout();
  if (route.meta.requiresAuth) {
    router.push({ name: "products-index" });
  }
}
</script>

<template>
  <header class="sticky top-0 z-50 bg-white border-b">
    <div class="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
      <RouterLink :to="{ name: 'products-index' }" class="font-bold">Birriamen</RouterLink>

      <nav class="flex items-center gap-2" :key="isAuthenticated ? 'auth' : 'guest'">
        <RouterLink
          v-if="isAuthenticated"
          :to="{ name: 'orders-admin' }"
          class="hidden sm:inline text-sm px-3 py-1.5 rounded hover:bg-gray-50"
        >
          Pedidos
        </RouterLink>

        <RouterLink
          v-if="isAuthenticated"
          :to="{ name: 'categories-index' }"
          class="hidden sm:inline text-sm px-3 py-1.5 rounded hover:bg-gray-50"
        >
          Categorías
        </RouterLink>

        <RouterLink
          :to="{ name: 'products-index' }"
          class="hidden sm:inline text-sm px-3 py-1.5 rounded hover:bg-gray-50"
        >
          Productos
        </RouterLink>

        <!-- público -->
        <RouterLink
          v-if="!isAuthenticated"
          :to="{ name: 'checkout' }"
          class="hidden sm:inline text-sm px-3 py-1.5 rounded hover:bg-gray-50"
        >
          Iniciar compra
        </RouterLink>

        <template v-if="!isAuthenticated">
          <button class="border rounded px-3 py-1.5 text-sm hover:bg-gray-50" @click="goLogin">
            Iniciar sesión
          </button>
        </template>

        <template v-else>
          <button
            class="border rounded px-3 py-1.5 text-sm hover:bg-red-50 text-red-700 border-red-200"
            @click="doLogout"
          >
            Cerrar sesión
          </button>
        </template>
      </nav>
    </div>

    <CategoryFilterBar
      v-if="showFilter"
      :model-value="props.categoryId ?? null"
      @update:modelValue="(v) => emit('update:category-id', v)"
    />
  </header>
</template>
