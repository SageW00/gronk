"""
Icon generator for Aerospace RAG application
Creates a simple but professional icon
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os

    def create_icon():
        """Create application icon"""
        # Create a 256x256 image with dark blue background
        size = 256
        img = Image.new('RGB', (size, size), color='#1a1a2e')
        draw = ImageDraw.Draw(img)

        # Draw a circular background
        circle_color = '#0f3460'
        padding = 20
        draw.ellipse([padding, padding, size-padding, size-padding], fill=circle_color)

        # Draw inner circle with gradient-like effect
        inner_color = '#16213e'
        inner_padding = 40
        draw.ellipse([inner_padding, inner_padding, size-inner_padding, size-inner_padding], fill=inner_color)

        # Draw the "A" for Aerospace (using simple shapes)
        # Main triangle for A
        draw.polygon([
            (size//2, 60),      # Top
            (80, size-60),       # Bottom left
            (size-80, size-60)   # Bottom right
        ], fill='#e94560')

        # Draw the horizontal bar of A
        bar_top = size - 110
        bar_height = 25
        draw.rectangle([
            90, bar_top,
            size-90, bar_top + bar_height
        ], fill='#e94560')

        # Cut out triangle in middle to make it look like A
        draw.polygon([
            (size//2, 100),     # Top
            (110, size-90),      # Bottom left
            (size-110, size-90)  # Bottom right
        ], fill=inner_color)

        # Save as multiple sizes for Windows ICO
        icon_dir = os.path.join(os.path.dirname(__file__), '..', '..')

        # Save as PNG for preview
        png_path = os.path.join(icon_dir, 'aerospace_rag_icon.png')
        img.save(png_path, 'PNG')
        print(f"✓ Created icon: {png_path}")

        # Create ICO file with multiple sizes
        ico_path = os.path.join(icon_dir, 'aerospace_rag_icon.ico')
        img.save(ico_path, format='ICO', sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
        print(f"✓ Created icon: {ico_path}")

        return ico_path

    if __name__ == '__main__':
        print("Creating Aerospace RAG icon...")
        create_icon()
        print("Icon creation complete!")

except ImportError:
    print("PIL (Pillow) not installed. Installing...")
    print("Run: pip install Pillow")
    print("\nAlternatively, you can use any PNG/ICO icon and name it 'aerospace_rag_icon.ico'")
