if Rails.env.production?
  abort "❌ Por seguridad, no ejecutes seeds en producción."
end

require "base64"
require "stringio"
require "securerandom"
ActiveRecord::Base.logger = nil

puts "Reseteando datos de categorías y productos…"
if defined?(OrderItem) && defined?(Order)
  OrderItem.destroy_all
  Order.destroy_all
end
Product.destroy_all
Category.destroy_all

PNG_BASE64_1x1 = <<~B64.delete("\n")
  iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAA
  AAC0lEQVR42mP8/x8AAwMCAO1m8kQAAAAASUVORK5CYII=
B64

def placeholder_io(filename: "placeholder.png")
  StringIO.new(Base64.decode64(PNG_BASE64_1x1)).tap do |io|
    io.set_encoding(Encoding::BINARY)
    io.rewind
  end
end

def attach_placeholder!(record)
  return if !record.respond_to?(:image) || record.image.attached?
  record.image.attach(
    io: placeholder_io,
    filename: "placeholder-#{SecureRandom.hex(4)}.png",
    content_type: "image/png"
  )
end

puts "Creando categorías…"
categories_seed = [
  { name: "Ramen",       description: "Caldo y fideos artesanales",   discount: 0  },
  { name: "Birria",      description: "Estilo Jalisco",               discount: 10 },
  { name: "Tacos",       description: "Tortilla de maíz recién hecha",discount: 0  },
  { name: "Entradas",    description: "Para compartir",               discount: 0  },
  { name: "Bebidas",     description: "Frías y calientes",            discount: 0  },
  { name: "Postres",     description: "Dulce final",                  discount: 0  },
  { name: "Especiales",  description: "Temporada / chef",             discount: 15 },
  { name: "Combos",      description: "Ahorra en combo",              discount: 10 },
  { name: "Promos",      description: "Promociones activas",          discount: 15 },
]

category_by_name = {}
Category.transaction do
  categories_seed.each do |attrs|
    c = Category.create!(attrs)
    category_by_name[c.name] = c
  end
end

def c!(name, category_by_name)
  category_by_name.fetch(name)
end

puts "Creando productos…"
products_seed = [
  {
    name: "Ramen Clásico",
    price: 29000,
    description: "Caldo tonkotsu, chashu, huevo marinado, cebollín.",
    available: true,
    categories: %w[Ramen]
  },
  {
    name: "Ramen de Birria",
    price: 34000,
    description: "Fusión caldo birria + ramen, cebollín y limón.",
    available: true,
    categories: %w[Ramen Birria Especiales]
  },
  {
    name: "Ramen Picante",
    price: 32000,
    description: "Base clásica con pasta de chile y óleo picante.",
    available: true,
    categories: %w[Ramen Especiales]
  },
  {
    name: "Tacos de Birria (3 u.)",
    price: 26000,
    description: "Maíz, birria, queso fundido y consomé.",
    available: true,
    categories: %w[Tacos Birria]
  },
  {
    name: "Tacos al Pastor (3 u.)",
    price: 24000,
    description: "Piña, cebolla, cilantro, salsa verde.",
    available: true,
    categories: %w[Tacos]
  },
  {
    name: "Gyozas (6 u.)",
    price: 15000,
    description: "Dumplings de cerdo/verduras con salsa ponzu.",
    available: true,
    categories: %w[Entradas]
  },
  {
    name: "Edamame",
    price: 11000,
    description: "Vainas de soya al vapor con sal marina.",
    available: true,
    categories: %w[Entradas]
  },
  {
    name: "Papas con Birria",
    price: 18000,
    description: "Papas rústicas con salsa y birria desmechada.",
    available: true,
    categories: %w[Entradas Birria]
  },
  {
    name: "Limonada Natural",
    price: 8000,
    description: "Refrescante, con toque de hierbabuena.",
    available: true,
    categories: %w[Bebidas]
  },
  {
    name: "Té Frío de Durazno",
    price: 8500,
    description: "Té negro infusionado, durazno.",
    available: true,
    categories: %w[Bebidas]
  },
  {
    name: "Brownie con Helado",
    price: 12000,
    description: "Chocolate intenso + bola de vainilla.",
    available: true,
    categories: %w[Postres]
  },
  {
    name: "Cheesecake de Frutos Rojos",
    price: 13000,
    description: "Base de galleta, coulis de frutos rojos.",
    available: true,
    categories: %w[Postres]
  },
  {
    name: "Combo Ramen + Bebida",
    price: 36000,
    description: "Ramen a elección + bebida (ahorra en combo).",
    available: true,
    categories: %w[Combos Ramen Bebidas]
  },
  {
    name: "Combo Tacos + Bebida",
    price: 32000,
    description: "Tacos (3 u.) + bebida (ahorra en combo).",
    available: true,
    categories: %w[Combos Tacos Bebidas]
  },
  {
    name: "Promo 2x1 Bebida",
    price: 9000,
    description: "Dos bebidas por el precio de una (aplican términos).",
    available: true,
    categories: %w[Promos Bebidas]
  },
]

Product.transaction do
  products_seed.each do |attrs|
    cats = attrs.delete(:categories) || []
    p = Product.new(attrs)
    attach_placeholder!(p)
    p.categories = cats.map { |n| c!(n, category_by_name) }
    p.save!
  end
end

puts " Listo. Categorías: #{Category.count}, Productos: #{Product.count}"
puts " Recuerda: los descuentos se calculan con el mayor 'discount' entre categorías del producto."
