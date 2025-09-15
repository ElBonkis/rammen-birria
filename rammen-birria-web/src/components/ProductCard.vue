<script setup lang="ts">
import { computed } from "vue";
import type { Product } from "@/api/products";

const props = defineProps<{ product: Product }>();
const emit = defineEmits<{ (e: "edit"): void; (e: "delete"): void }>();

const currency = (n: number | string) =>
  new Intl.NumberFormat("es-MX", {
    style: "currency",
    currency: "MXN",
    maximumFractionDigits: 0,
  }).format(Number(n));

const imageSrc = computed(() => props.product.image_url || null);

const priceFinal = computed(() =>
  Number(props.product.price_with_discount ?? props.product.price)
);

const hasDiscount = computed(() => {
  const base = Number(props.product.price);
  return priceFinal.value > 0 && base > 0 && priceFinal.value < base;
});

const discountPercent = computed(() => {
  const p = props.product as any;
  if (typeof p.discount_percent === "number") return p.discount_percent;
  const base = Number(props.product.price);
  const final = priceFinal.value;
  if (!base || final >= base) return 0;
  return Math.round((1 - final / base) * 100);
});
</script>

<template>
  <article class="group rounded-xl border bg-white p-4 shadow-sm hover:shadow-md transition">
    <div class="flex items-start justify-between gap-4">
      <div class="shrink-0">
        <div class="h-24 w-24 overflow-hidden rounded-lg ring-1 ring-gray-200">
          <img
            v-if="imageSrc"
            :src="imageSrc"
            :alt="product.name"
            loading="lazy"
            class="h-full w-full object-cover"
          />
          <div v-else class="flex h-full w-full items-center justify-center bg-gray-50 text-gray-400">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" viewBox="0 0 24 24" fill="currentColor">
              <path d="M21 19V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14m18 0H3m18 0-5.5-7-4 5-2.5-3L3 19" />
            </svg>
          </div>
        </div>
      </div>

      <div class="ml-auto flex items-center gap-2">
        <button class="btn-ghost" title="Editar" @click="emit('edit')">Editar</button>
        <button class="btn-danger" title="Eliminar" @click="emit('delete')">Eliminar</button>
      </div>
    </div>

    <div class="mt-3">
      <h3 class="font-semibold leading-tight line-clamp-1">{{ product.name }}</h3>
      <p class="mt-1 text-sm text-gray-500 line-clamp-2">
        {{ product.description || "Sin descripción" }}
      </p>

      <div class="mt-3 flex items-baseline gap-2">
        <span v-if="hasDiscount" class="text-sm text-gray-400 line-through">
          {{ currency(product.price) }}
        </span>
        <span class="text-indigo-700 font-semibold">
          {{ currency(priceFinal) }}
        </span>
        <span v-if="hasDiscount" class="badge-discount">-{{ discountPercent }}%</span>
      </div>
    </div>
  </article>
</template>

<style scoped>
.btn-ghost {
  @apply inline-flex items-center rounded-md border border-gray-200 px-3 py-1.5 text-sm
         text-gray-700 hover:bg-gray-50 active:bg-gray-100 transition;
}
.btn-danger {
  @apply inline-flex items-center rounded-md bg-red-600 px-3 py-1.5 text-sm
         text-white hover:bg-red-700 active:bg-red-800 transition;
}
.badge-discount {
  @apply inline-flex items-center text-[10px] rounded-full bg-indigo-50 text-indigo-700
         border border-indigo-100 px-2 py-0.5;
}
/* recorte elegante de texto si es largo */
.line-clamp-1 { display:-webkit-box; -webkit-line-clamp:1; -webkit-box-orient:vertical; overflow:hidden; }
.line-clamp-2 { display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
</style>
