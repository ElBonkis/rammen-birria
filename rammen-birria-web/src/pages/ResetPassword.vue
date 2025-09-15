<script setup lang="ts">
import { ref } from "vue";
import { useRoute, useRouter, RouterLink } from "vue-router";
import { useAuth } from "@/stores/auth";
import { useFormErrors } from "@/composables/useFormErrors";

const route = useRoute();
const router = useRouter();
const auth = useAuth();

const email = ref<string>((route.query.email as string) || "");
const token = ref<string>((route.query.token as string) || "");
const password = ref("");
const confirm  = ref("");
const loading  = ref(false);
const success  = ref(false);

const { generalError, fieldErrors, firstError, clearErrors, setErrorsFromAxios } = useFormErrors();

async function submit() {
  clearErrors(); success.value = false;

  if (password.value !== confirm.value) {
    (fieldErrors.value.password ||= []).push("Las contraseñas no coinciden");
    return;
  }

  loading.value = true;
  try {
    await auth.resetPassword(email.value, token.value, password.value, confirm.value);
    success.value = true;
    setTimeout(() => router.push({ path: "/login" }), 1200);
  } catch (e:any) {
    setErrorsFromAxios(e);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="w-full max-w-md bg-white shadow-lg rounded-2xl p-8">
      <h1 class="text-2xl font-semibold text-center mb-4">Restablecer contraseña</h1>

      <div v-if="success" class="mb-3 rounded bg-green-100 text-green-800 px-3 py-2 text-sm">
        Contraseña actualizada. Redirigiendo al inicio de sesión…
      </div>
      <div v-if="generalError" class="mb-3 rounded bg-red-50 text-red-700 px-3 py-2 text-sm whitespace-pre-line">
        {{ generalError }}
      </div>

      <form @submit.prevent="submit" class="space-y-4">
        <input v-model="email" type="email" placeholder="Correo"
               class="w-full rounded-lg border px-3 py-2" />
        <input v-model="token" type="text" placeholder="Token"
               class="w-full rounded-lg border px-3 py-2" />

        <div>
          <input v-model="password" type="password" placeholder="Nueva contraseña"
                 class="w-full rounded-lg border px-3 py-2" />
          <p v-if="firstError('password')" class="text-sm text-red-600 mt-1">{{ firstError('password') }}</p>
        </div>

        <input v-model="confirm" type="password" placeholder="Confirmar contraseña"
               class="w-full rounded-lg border px-3 py-2" />

        <button :disabled="loading" class="w-full bg-indigo-600 text-white rounded-lg py-2.5">
          {{ loading ? "Actualizando..." : "Cambiar contraseña" }}
        </button>
      </form>

      <p class="text-center text-sm text-gray-600 mt-6">
        <RouterLink to="/login" class="text-indigo-600 hover:underline">Volver al inicio de sesión</RouterLink>
      </p>
    </div>
  </div>
</template>
