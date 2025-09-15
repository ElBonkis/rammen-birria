<script setup lang="ts">
import { ref, computed } from "vue";
import { useRouter, useRoute, RouterLink } from "vue-router";
import { useAuth } from "@/stores/auth";
import { useFormErrors } from "@/composables/useFormErrors";

const route = useRoute();
const router = useRouter();
const auth = useAuth();

const email = ref("");
const password = ref("");
const loading = ref(false);

const { generalError, clearErrors, setErrorsFromAxios } = useFormErrors();
const justRegistered = computed(() => route.query.registered === "1");

async function submit() {
  clearErrors();
  loading.value = true;
  try {
    await auth.login(email.value, password.value);
    router.push((route.query.redirect as string) || "/products");
  } catch (e: any) {
    setErrorsFromAxios(e);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="w-full max-w-md bg-white shadow-lg rounded-2xl p-8">
      <h1 class="text-2xl font-semibold text-gray-800 mb-4 text-center">Iniciar sesión</h1>

      <div v-if="justRegistered" class="mb-4 rounded-lg bg-green-100 text-green-800 px-3 py-2 text-sm">
        Usuario registrado con éxito. Ahora puedes iniciar sesión.
      </div>

      <div v-if="generalError" class="mb-4 rounded-lg bg-red-50 text-red-700 px-3 py-2 text-sm whitespace-pre-line">
        {{ generalError }}
      </div>

      <form @submit.prevent="submit" class="space-y-4">
        <input
          v-model="email"
          type="email"
          placeholder="Email"
          class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        <input
          v-model="password"
          type="password"
          placeholder="Contraseña"
          class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />

        <button
          :disabled="loading"
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white font-medium py-2.5 rounded-lg transition"
        >
          {{ loading ? "Entrando..." : "Entrar" }}
        </button>
      </form>

      <p class="text-center text-sm mt-3">
        <RouterLink to="/forgot-password" class="text-indigo-600 hover:underline">
          ¿Olvidaste tu contraseña?
        </RouterLink>
      </p>


      <p class="text-center text-sm text-gray-600 mt-6">
        ¿No tienes cuenta?
        <RouterLink to="/register" class="text-indigo-600 hover:underline font-medium">Regístrate</RouterLink>
      </p>
    </div>
  </div>
</template>
