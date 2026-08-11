---
name: Luxury Earth Futurist
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1b1b1b'
  surface-container: '#1f1f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#cac6bb'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#303030'
  outline: '#949187'
  outline-variant: '#49473f'
  surface-tint: '#cbc7b4'
  primary: '#fef8e5'
  on-primary: '#333124'
  primary-container: '#e1dcc9'
  on-primary-container: '#636151'
  inverse-primary: '#615f50'
  secondary: '#e1c19f'
  on-secondary: '#402c14'
  secondary-container: '#5b452b'
  on-secondary-container: '#d3b392'
  tertiary: '#fff7f2'
  on-tertiary: '#3a2e24'
  tertiary-container: '#edd8c9'
  on-tertiary-container: '#6c5d51'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e8e3cf'
  primary-fixed-dim: '#cbc7b4'
  on-primary-fixed: '#1d1c10'
  on-primary-fixed-variant: '#494739'
  secondary-fixed: '#ffddb9'
  secondary-fixed-dim: '#e1c19f'
  on-secondary-fixed: '#291803'
  on-secondary-fixed-variant: '#594329'
  tertiary-fixed: '#f3dfcf'
  tertiary-fixed-dim: '#d7c3b4'
  on-tertiary-fixed: '#241910'
  on-tertiary-fixed-variant: '#524439'
  background: '#131313'
  on-background: '#e2e2e2'
  surface-variant: '#353535'
typography:
  display-lg:
    fontFamily: Lexend
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Lexend
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Lexend
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  title-md:
    fontFamily: Lexend
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max-width: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
---

## Brand & Style
The brand personality is rooted in "Organic Futurism"—a synthesis of high-technology and geological permanence. It targets a premium audience seeking sophisticated, calm, and highly tactile digital environments. 

The design style merges **Glassmorphism** with **Neomorphism**, creating a "haptic digital" experience. UI elements should feel like polished stone or semi-translucent resin, utilizing soft light-leaks and subtle depth to evoke an emotional response of grounded stability and quiet luxury.

## Colors
The palette shifts from aquatic tones to a "Luxury Earth" spectrum. 
- **Deep Espresso (#1F150C)** and **Pure Black (#000000)** serve as the foundation, providing a rich, cavernous depth.
- **Rich Brown (#412D15)** acts as the secondary surface color, bridging the gap between darkness and light.
- **Soft Cream (#E1DCC9)** is the primary accent and typography color, providing high-contrast readability and a warm, ivory-like finish.

Use transparency (10% to 40%) of the Soft Cream for glass surfaces to create the "frosted resin" effect against the dark backgrounds.

## Typography
Lexend is utilized across all levels to maintain a clean, athletic, yet highly readable geometric profile. 
- **Headlines:** Use tighter letter-spacing for large display sizes to create a compact, premium feel. 
- **Body:** Maintain standard tracking to ensure the low-contrast "Soft Cream on Espresso" pairings remain legible.
- **Labels:** Use uppercase and increased tracking for small labels to reference high-end horology or architectural signage.

## Layout & Spacing
The layout follows a **Fluid Grid** system based on an 8px base unit. 
- **Desktop:** A 12-column grid with generous 64px outer margins to emphasize whitespace as a luxury commodity.
- **Mobile:** A 4-column grid with 16px margins.
- **Rhythm:** Use large vertical gaps (80px+) between major sections to allow the "tactile" components room to breathe and avoid visual clutter.

## Elevation & Depth
Depth is achieved through a combination of **Neomorphic extrusions** and **Glassmorphic overlays**:
- **Base Surfaces:** Deep Espresso (#1F150C).
- **Raised Elements:** Use subtle dual-shadows. A "light leak" (Soft Cream at 5% opacity) on the top-left and a "deep shadow" (Black at 40% opacity) on the bottom-right.
- **Overlays:** Soft Cream surfaces with a 20px backdrop-blur and 15% opacity to create a "floating silt" effect.
- **Interactive States:** On press, elements should "sink" by reversing the shadow direction, simulating physical displacement.

## Shapes
Following the "ROUND_EIGHT" directive, the design system utilizes a **Rounded (2)** logic. 
- Standard components (buttons, inputs) use **0.5rem (8px)** corner radii. 
- Larger containers and cards use **1rem (16px)** to maintain a soft, pebble-like silhouette that feels organic rather than industrial. 
- Avoid completely sharp corners to prevent the UI from feeling aggressive.

## Components
- **Buttons:** Primary buttons are Soft Cream with Deep Espresso text. Secondary buttons are "ghost" style with a 1px Soft Cream border at 20% opacity and a subtle backdrop blur.
- **Cards:** Use a Rich Brown (#412D15) background with a 1px inner "light" stroke on the top edge to simulate a beveled stone edge.
- **Input Fields:** Recessed neomorphic style (inner shadows) to look carved into the interface, using Soft Cream for the cursor and input text.
- **Chips:** Highly rounded (pill-shaped) with a translucent Soft Cream fill and no border, functioning as "polished sea-glass" markers.
- **Lists:** Separated by thin, 1px horizontal lines using Rich Brown at 40% opacity to maintain a clean, minimal list structure.