---
name: Terra Lux Futura
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1b1b1b'
  on-surface-variant: '#4e453d'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#80756b'
  outline-variant: '#d1c4b9'
  surface-tint: '#735a3e'
  primary: '#2a1804'
  on-primary: '#ffffff'
  primary-container: '#412d15'
  on-primary-container: '#b19474'
  inverse-primary: '#e1c19f'
  secondary: '#4c6706'
  on-secondary: '#ffffff'
  secondary-container: '#cdef84'
  on-secondary-container: '#526d0f'
  tertiary: '#1e1c10'
  on-tertiary: '#ffffff'
  tertiary-container: '#333124'
  on-tertiary-container: '#9d9988'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffddb9'
  primary-fixed-dim: '#e1c19f'
  on-primary-fixed: '#291803'
  on-primary-fixed-variant: '#594329'
  secondary-fixed: '#cdef84'
  secondary-fixed-dim: '#b2d26b'
  on-secondary-fixed: '#141f00'
  on-secondary-fixed-variant: '#384e00'
  tertiary-fixed: '#e8e3cf'
  tertiary-fixed-dim: '#cbc7b4'
  on-tertiary-fixed: '#1d1c10'
  on-tertiary-fixed-variant: '#494739'
  background: '#fcf9f8'
  on-background: '#1b1b1b'
  surface-variant: '#e5e2e1'
typography:
  display-lg:
    fontFamily: Lexend
    fontSize: 56px
    fontWeight: '600'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Lexend
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Lexend
    fontSize: 28px
    fontWeight: '500'
    lineHeight: 36px
  title-md:
    fontFamily: Lexend
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '300'
    lineHeight: 28px
  body-md:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '300'
    lineHeight: 24px
  label-md:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style

The design system embodies a "Luxury Earth Futurist" aesthetic—a synthesis of organic warmth and precision engineering. It is designed for high-end sustainable brands, architectural platforms, or premium wellness services. The goal is to evoke a sense of grounded luxury: the feeling of a sun-drenched, minimalist villa that utilizes cutting-edge technology.

The visual style combines **Neomorphism** (for tactile, physical interaction) with **Glassmorphism** (for futuristic depth). Elements should feel like they are carved from or resting upon natural stone and clay, utilizing soft light-and-shadow plays to define hierarchy rather than heavy lines. The emotional response is one of calm, professional reliability, and quiet sophistication.

## Colors

The palette is rooted in an earthy, high-contrast spectrum.
- **Primary (Deep Espresso):** Used for core branding, primary calls to action, and high-level headings. It provides the "anchor" for the design.
- **Secondary (Olive):** Used for success states, active indicators, and organic accents that connect the UI to nature.
- **Accent (Cream):** A soft, sophisticated hue used for subtle backgrounds, secondary buttons, and decorative elements.
- **Surface & Container:** The pure white surface provides clarity, while the "F8F5F1" container creates a soft, clay-like warmth for grouped content.
- **Text:** Almost black (#1B1B1B) to ensure maximum legibility against the warm neutrals.

## Typography

This design system exclusively utilizes **Lexend**. Chosen for its exceptional readability and geometric clarity, it bridges the gap between technical precision and friendly approachability. 

- **Headlines:** Use Medium (500) or SemiBold (600) weights with slight negative letter-spacing to create a tight, editorial feel.
- **Body Text:** Use Light (300) weight for long-form content to maintain an airy, premium feel. The increased line height ensures a relaxed reading experience.
- **Labels:** Always use Medium or SemiBold with increased letter-spacing and Uppercase transformations for a "gallery" or "architectural" tagging style.

## Layout & Spacing

The design system employs a **Fluid Grid** model based on an 8px rhythm. 

- **Desktop:** 12-column grid with 64px outer margins. Content is often centered with significant whitespace (xl spacing) to emphasize the premium nature of the brand.
- **Tablet:** 8-column grid with 32px margins.
- **Mobile:** 4-column grid with 16px margins. 

Spacing should be generous. Use "lg" (48px) spacing between major sections to allow the UI to "breathe." Avoid crowding elements; the luxury comes from the space between the objects.

## Elevation & Depth

Depth is communicated through two primary methods:

1.  **Soft Neumorphism:** For interactive elements like cards and buttons, use dual shadows. A "light" shadow (White, -4px -4px, 12px blur) and a "soft" shadow (Darker beige/clay, 4px 4px, 12px blur). This creates the illusion that the UI is molded from the background surface.
2.  **High-Blur Frosted Glass:** For navigation bars and overlay modals, use a backdrop filter (blur: 24px) combined with a semi-transparent White (#FFFFFF80) fill. This provides a futuristic, airy contrast to the solid, earthy Neumorphic elements.
3.  **Hierarchy:** Level 0 is the Surface. Level 1 is the Surface Container. Level 2 elements are "extruded" using the soft neumorphic shadows.

## Shapes

The shape language is consistently "Rounded Eight" (0.5rem / 8px). This radius is large enough to feel friendly and organic, but precise enough to remain professional and architectural.

- **Standard Elements:** 8px (0.5rem) for input fields, small buttons, and chips.
- **Large Elements:** 16px (1rem) for cards and main containers.
- **Extra Large:** 24px (1.5rem) for modals and featured hero sections.
- **Circular:** Reserved exclusively for user avatars and icon backgrounds.

## Components

- **Buttons:** Primary buttons use the Deep Espresso (#412D15) background with White text. Secondary buttons should use the Neumorphic extrusion effect (Cream background with soft shadows) to appear tactile.
- **Input Fields:** Fields should appear slightly "sunken" into the surface using an inner shadow, emphasizing the physical, clay-like nature of the UI. Use Lexend Label-md for placeholder text.
- **Cards:** Cards use the Surface Container (#F8F5F1) color. They do not have borders; instead, they are defined by the "Rounded Eight" corners and the soft Neumorphic shadow play.
- **Chips:** Small, pill-shaped elements using the Olive (#7C9A3A) color at 10% opacity for the background and 100% opacity for the text.
- **Glass Overlays:** Use for top navigation bars. The text should be Deep Espresso, floating over the high-blur frosted glass to maintain readability while showing a hint of the content beneath.
- **Selection Controls:** Checkboxes and Radio buttons should use the Olive color when active, providing a vibrant "growth" signal against the neutral base.