"""
GUI interface for Aerospace RAG application using CustomTkinter
"""

import customtkinter as ctk
from tkinter import scrolledtext, messagebox, filedialog
import threading
import sys
from pathlib import Path
from typing import Optional

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from aerospace_rag.core.rag_engine import RAGEngine
from aerospace_rag.core.config import get_config


class AerospaceRAGGUI:
    """Main GUI application for Aerospace RAG"""

    def __init__(self):
        # Set appearance
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        # Create main window
        self.root = ctk.CTk()
        self.root.title("Aerospace RAG Assistant - AI-Powered Aerospace Learning")
        self.root.geometry("1200x800")

        # Set minimum window size
        self.root.minsize(1000, 600)

        # Center window on screen
        self.center_window()

        # Initialize RAG engine
        self.rag: Optional[RAGEngine] = None
        self.config = get_config()

        # Setup UI
        self.setup_ui()

        # Try to initialize RAG engine
        self.initialize_rag()

    def setup_ui(self):
        """Setup the user interface"""
        # Configure grid
        self.root.grid_columnconfigure(1, weight=1)
        self.root.grid_rowconfigure(0, weight=1)

        # Create sidebar
        self.create_sidebar()

        # Create main content area
        self.create_main_area()

        # Create status bar
        self.create_status_bar()

    def create_sidebar(self):
        """Create sidebar with controls"""
        sidebar = ctk.CTkFrame(self.root, width=250, corner_radius=0)
        sidebar.grid(row=0, column=0, rowspan=2, sticky="nsew")
        sidebar.grid_rowconfigure(10, weight=1)

        # Title
        title = ctk.CTkLabel(
            sidebar,
            text="Aerospace RAG",
            font=ctk.CTkFont(size=20, weight="bold")
        )
        title.grid(row=0, column=0, padx=20, pady=(20, 10))

        subtitle = ctk.CTkLabel(
            sidebar,
            text="AI-Powered Aerospace Assistant",
            font=ctk.CTkFont(size=12)
        )
        subtitle.grid(row=1, column=0, padx=20, pady=(0, 20))

        # Course filter
        ctk.CTkLabel(sidebar, text="Filter by Course:", anchor="w").grid(
            row=2, column=0, padx=20, pady=(10, 0), sticky="w"
        )

        courses = ["All Courses"] + list(self.config.courses.keys())
        self.course_var = ctk.StringVar(value="All Courses")
        self.course_dropdown = ctk.CTkOptionMenu(
            sidebar,
            variable=self.course_var,
            values=courses
        )
        self.course_dropdown.grid(row=3, column=0, padx=20, pady=10)

        # Top-K slider
        ctk.CTkLabel(sidebar, text="Number of Sources:", anchor="w").grid(
            row=4, column=0, padx=20, pady=(10, 0), sticky="w"
        )

        self.topk_var = ctk.IntVar(value=5)
        self.topk_slider = ctk.CTkSlider(
            sidebar,
            from_=1,
            to=10,
            number_of_steps=9,
            variable=self.topk_var
        )
        self.topk_slider.grid(row=5, column=0, padx=20, pady=10)

        self.topk_label = ctk.CTkLabel(sidebar, text="5")
        self.topk_label.grid(row=6, column=0, padx=20, pady=(0, 10))

        def update_topk_label(value):
            self.topk_label.configure(text=str(int(float(value))))

        self.topk_slider.configure(command=update_topk_label)

        # Buttons
        self.index_button = ctk.CTkButton(
            sidebar,
            text="Index Documents",
            command=self.index_documents
        )
        self.index_button.grid(row=7, column=0, padx=20, pady=10)

        self.stats_button = ctk.CTkButton(
            sidebar,
            text="View Statistics",
            command=self.show_statistics
        )
        self.stats_button.grid(row=8, column=0, padx=20, pady=10)

        self.clear_button = ctk.CTkButton(
            sidebar,
            text="Clear Chat",
            command=self.clear_chat
        )
        self.clear_button.grid(row=9, column=0, padx=20, pady=10)

        # System status indicator
        self.status_indicator = ctk.CTkLabel(
            sidebar,
            text="● Disconnected",
            text_color="red",
            font=ctk.CTkFont(size=12)
        )
        self.status_indicator.grid(row=11, column=0, padx=20, pady=(0, 20))

    def create_main_area(self):
        """Create main chat area"""
        main_frame = ctk.CTkFrame(self.root)
        main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        main_frame.grid_rowconfigure(0, weight=1)
        main_frame.grid_columnconfigure(0, weight=1)

        # Chat display area
        self.chat_display = ctk.CTkTextbox(
            main_frame,
            wrap="word",
            font=ctk.CTkFont(size=13)
        )
        self.chat_display.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")

        # Input frame
        input_frame = ctk.CTkFrame(main_frame)
        input_frame.grid(row=1, column=0, padx=10, pady=(0, 10), sticky="ew")
        input_frame.grid_columnconfigure(0, weight=1)

        # Question input
        self.question_entry = ctk.CTkEntry(
            input_frame,
            placeholder_text="Ask a question about aerospace topics...",
            height=40,
            font=ctk.CTkFont(size=13)
        )
        self.question_entry.grid(row=0, column=0, padx=(0, 10), pady=10, sticky="ew")
        self.question_entry.bind("<Return>", lambda e: self.ask_question())

        # Ask button
        self.ask_button = ctk.CTkButton(
            input_frame,
            text="Ask",
            command=self.ask_question,
            width=100,
            height=40,
            font=ctk.CTkFont(size=13, weight="bold")
        )
        self.ask_button.grid(row=0, column=1, padx=0, pady=10)

        # Add welcome message
        self.add_system_message(
            "Welcome to Aerospace RAG Assistant!\n\n"
            "I can help you understand aerospace concepts from MIT OCW course materials.\n"
            "Ask me anything about aerodynamics, propulsion, structural mechanics, and more!"
        )

    def create_status_bar(self):
        """Create status bar at bottom"""
        status_frame = ctk.CTkFrame(self.root, height=30)
        status_frame.grid(row=1, column=1, padx=20, pady=(0, 20), sticky="ew")

        self.status_label = ctk.CTkLabel(
            status_frame,
            text="Ready",
            font=ctk.CTkFont(size=11)
        )
        self.status_label.pack(side="left", padx=10, pady=5)

    def initialize_rag(self):
        """Initialize RAG engine in background"""
        def init():
            try:
                self.update_status("Initializing RAG system...")
                self.rag = RAGEngine()
                self.rag.initialize()
                self.update_status("Ready")
                self.update_status_indicator("● Connected", "green")
            except Exception as e:
                self.update_status(f"Initialization failed: {e}")
                self.update_status_indicator("● Error", "orange")
                messagebox.showerror("Initialization Error", str(e))

        thread = threading.Thread(target=init, daemon=True)
        thread.start()

    def ask_question(self):
        """Handle question submission"""
        question = self.question_entry.get().strip()

        if not question:
            return

        if not self.rag:
            messagebox.showwarning("Not Ready", "System is still initializing. Please wait.")
            return

        # Disable input
        self.ask_button.configure(state="disabled")
        self.question_entry.configure(state="disabled")

        # Add question to chat
        self.add_user_message(question)

        # Clear input
        self.question_entry.delete(0, "end")

        # Process query in background
        def query():
            try:
                self.update_status("Searching for relevant information...")

                # Get filter settings
                course = None if self.course_var.get() == "All Courses" else self.course_var.get()
                top_k = self.topk_var.get()

                # Query RAG
                result = self.rag.query(
                    question,
                    course_code=course,
                    top_k=top_k,
                    stream=False
                )

                self.update_status("Ready")

                # Add answer to chat
                self.add_assistant_message(result['answer'], result['sources'])

            except Exception as e:
                self.update_status("Query failed")
                self.add_error_message(f"Error: {e}")

            finally:
                # Re-enable input
                self.ask_button.configure(state="normal")
                self.question_entry.configure(state="normal")

        thread = threading.Thread(target=query, daemon=True)
        thread.start()

    def add_user_message(self, message: str):
        """Add user message to chat"""
        self.chat_display.configure(state="normal")
        self.chat_display.insert("end", "\n" + "="*80 + "\n")
        self.chat_display.insert("end", "You: ", "user_tag")
        self.chat_display.insert("end", message + "\n", "user_message")
        self.chat_display.tag_config("user_tag", foreground="#4A9EFF", font=("Arial", 13, "bold"))
        self.chat_display.tag_config("user_message", foreground="#FFFFFF")
        self.chat_display.see("end")
        self.chat_display.configure(state="disabled")

    def add_assistant_message(self, message: str, sources: list):
        """Add assistant message to chat"""
        self.chat_display.configure(state="normal")
        self.chat_display.insert("end", "\nAssistant: ", "assistant_tag")
        self.chat_display.insert("end", message + "\n", "assistant_message")

        if sources:
            self.chat_display.insert("end", "\n📚 Sources:\n", "sources_tag")
            for i, source in enumerate(sources, 1):
                source_text = (
                    f"  [{i}] {source['course_code']}: {source['course_name']} "
                    f"({source['content_type']}, {source['file_name']}, "
                    f"page {source['page_number']}) "
                    f"[similarity: {source['similarity']:.3f}]\n"
                )
                self.chat_display.insert("end", source_text, "source_item")

        self.chat_display.tag_config("assistant_tag", foreground="#4AFF8C", font=("Arial", 13, "bold"))
        self.chat_display.tag_config("assistant_message", foreground="#FFFFFF")
        self.chat_display.tag_config("sources_tag", foreground="#FFB84A", font=("Arial", 12, "bold"))
        self.chat_display.tag_config("source_item", foreground="#CCCCCC", font=("Arial", 11))
        self.chat_display.see("end")
        self.chat_display.configure(state="disabled")

    def add_system_message(self, message: str):
        """Add system message to chat"""
        self.chat_display.configure(state="normal")
        self.chat_display.insert("end", "\n" + "="*80 + "\n")
        self.chat_display.insert("end", "System: ", "system_tag")
        self.chat_display.insert("end", message + "\n", "system_message")
        self.chat_display.tag_config("system_tag", foreground="#FF8C4A", font=("Arial", 13, "bold"))
        self.chat_display.tag_config("system_message", foreground="#FFFFFF")
        self.chat_display.see("end")
        self.chat_display.configure(state="disabled")

    def add_error_message(self, message: str):
        """Add error message to chat"""
        self.chat_display.configure(state="normal")
        self.chat_display.insert("end", "\n❌ ", "error_tag")
        self.chat_display.insert("end", message + "\n", "error_message")
        self.chat_display.tag_config("error_tag", foreground="#FF4A4A")
        self.chat_display.tag_config("error_message", foreground="#FF8888")
        self.chat_display.see("end")
        self.chat_display.configure(state="disabled")

    def clear_chat(self):
        """Clear chat history"""
        self.chat_display.configure(state="normal")
        self.chat_display.delete("1.0", "end")
        self.chat_display.configure(state="disabled")
        self.add_system_message("Chat cleared. Ready for new questions!")

    def index_documents(self):
        """Index documents from PDFs"""
        if not self.rag:
            messagebox.showwarning("Not Ready", "System is still initializing. Please wait.")
            return

        course = None if self.course_var.get() == "All Courses" else self.course_var.get()

        response = messagebox.askyesno(
            "Index Documents",
            f"This will index {'all courses' if not course else course}.\n"
            "This may take several minutes. Continue?"
        )

        if not response:
            return

        self.index_button.configure(state="disabled")

        def index():
            try:
                self.update_status("Indexing documents...")
                self.rag.index_documents(course_code=course)
                self.update_status("Ready")
                messagebox.showinfo("Success", "Documents indexed successfully!")
            except Exception as e:
                self.update_status("Indexing failed")
                messagebox.showerror("Indexing Error", str(e))
            finally:
                self.index_button.configure(state="normal")

        thread = threading.Thread(target=index, daemon=True)
        thread.start()

    def show_statistics(self):
        """Show system statistics"""
        if not self.rag:
            messagebox.showwarning("Not Ready", "System is still initializing. Please wait.")
            return

        def get_stats():
            try:
                stats = self.rag.get_statistics()

                stats_text = f"""
Aerospace RAG System Statistics

Total Documents: {stats['total_documents']}
Configured Courses: {stats['configured_courses']}
Indexed Courses: {len(stats['courses'])}

Course Breakdown:
"""
                for course in stats['courses']:
                    stats_text += f"  • {course['course_code']}: {course['course_name']}\n"
                    stats_text += f"    Documents: {course['document_count']}\n"

                messagebox.showinfo("System Statistics", stats_text)

            except Exception as e:
                messagebox.showerror("Error", f"Failed to get statistics: {e}")

        thread = threading.Thread(target=get_stats, daemon=True)
        thread.start()

    def update_status(self, message: str):
        """Update status bar"""
        self.root.after(0, lambda: self.status_label.configure(text=message))

    def update_status_indicator(self, text: str, color: str):
        """Update status indicator"""
        self.root.after(0, lambda: self.status_indicator.configure(text=text, text_color=color))

    def center_window(self):
        """Center the window on the screen"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()
        x = (screen_width - width) // 2
        y = (screen_height - height) // 2
        self.root.geometry(f"{width}x{height}+{x}+{y}")

    def run(self):
        """Start the GUI application"""
        self.root.mainloop()


def main():
    """Main entry point for GUI"""
    app = AerospaceRAGGUI()
    app.run()


if __name__ == "__main__":
    main()
