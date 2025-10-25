"""
CLI interface for Aerospace RAG application
"""

import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.markdown import Markdown
from rich.progress import Progress, SpinnerColumn, TextColumn
from typing import Optional
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from aerospace_rag.core.rag_engine import RAGEngine
from aerospace_rag.core.config import get_config

app = typer.Typer(
    name="aerospace-rag",
    help="Aerospace RAG CLI - AI-powered aerospace course assistant",
    add_completion=False
)
console = Console()


@app.command()
def init():
    """Initialize the RAG system and database"""
    try:
        console.print("\n[bold cyan]Initializing Aerospace RAG System...[/bold cyan]\n")

        rag = RAGEngine()
        rag.initialize()

        console.print("\n[bold green]✓ System initialized successfully![/bold green]\n")
        console.print("Next steps:")
        console.print("  1. Place your PDF files in data/coursenotes/<course_code>/ or data/textbook/<course_code>/")
        console.print("  2. Run: aerospace-rag index")
        console.print("  3. Start querying: aerospace-rag query \"your question\"\n")

        rag.close()

    except Exception as e:
        console.print(f"[bold red]✗ Initialization failed: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def index(
    course: Optional[str] = typer.Option(None, "--course", "-c", help="Specific course code to index")
):
    """Index PDF documents into the database"""
    try:
        console.print("\n[bold cyan]Starting document indexing...[/bold cyan]\n")

        rag = RAGEngine()
        rag.initialize()

        with console.status("[bold yellow]Indexing documents...[/bold yellow]"):
            rag.index_documents(course_code=course)

        console.print("\n[bold green]✓ Indexing completed successfully![/bold green]\n")

        rag.close()

    except Exception as e:
        console.print(f"[bold red]✗ Indexing failed: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def query(
    question: str = typer.Argument(..., help="Your question about aerospace topics"),
    course: Optional[str] = typer.Option(None, "--course", "-c", help="Filter by course code"),
    top_k: Optional[int] = typer.Option(None, "--top-k", "-k", help="Number of sources to retrieve"),
    stream: bool = typer.Option(False, "--stream", "-s", help="Stream the response")
):
    """Query the RAG system with a question"""
    try:
        rag = RAGEngine()
        rag.initialize()

        console.print(Panel(
            f"[bold cyan]Question:[/bold cyan] {question}",
            border_style="cyan"
        ))

        result = rag.query(question, course_code=course, top_k=top_k, stream=stream)

        console.print("\n" + "="*80 + "\n")

        # Display answer
        console.print(Panel(
            Markdown(result['answer']),
            title="[bold green]Answer[/bold green]",
            border_style="green"
        ))

        # Display sources
        if result['sources']:
            console.print("\n[bold cyan]Sources:[/bold cyan]\n")

            table = Table(show_header=True, header_style="bold magenta")
            table.add_column("#", style="dim", width=3)
            table.add_column("Course", style="cyan")
            table.add_column("Type", style="yellow")
            table.add_column("File", style="green")
            table.add_column("Page", style="blue")
            table.add_column("Similarity", style="magenta")

            for i, source in enumerate(result['sources'], 1):
                table.add_row(
                    str(i),
                    f"{source['course_code']}: {source['course_name']}",
                    source['content_type'],
                    source['file_name'],
                    str(source['page_number']),
                    f"{source['similarity']:.3f}"
                )

            console.print(table)

        console.print("\n")
        rag.close()

    except Exception as e:
        console.print(f"[bold red]✗ Query failed: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def interactive(
    course: Optional[str] = typer.Option(None, "--course", "-c", help="Filter by course code")
):
    """Start interactive query mode"""
    try:
        rag = RAGEngine()
        rag.initialize()

        console.print(Panel(
            "[bold cyan]Aerospace RAG Interactive Mode[/bold cyan]\n\n"
            "Type your questions and get AI-powered answers from MIT aerospace course materials.\n"
            "Commands: 'exit', 'quit' - Exit the session\n"
            "          'stats' - Show system statistics",
            border_style="cyan"
        ))

        while True:
            console.print("\n[bold yellow]Your question:[/bold yellow] ", end="")
            question = input().strip()

            if question.lower() in ['exit', 'quit']:
                console.print("\n[bold green]Goodbye![/bold green]\n")
                break

            if question.lower() == 'stats':
                stats = rag.get_statistics()
                console.print(f"\n[bold cyan]System Statistics:[/bold cyan]")
                console.print(f"  Total documents: {stats['total_documents']}")
                console.print(f"  Configured courses: {stats['configured_courses']}")
                console.print(f"  Indexed courses: {len(stats['courses'])}\n")
                continue

            if not question:
                continue

            result = rag.query(question, course_code=course)

            console.print("\n" + "-"*80 + "\n")
            console.print(Panel(
                Markdown(result['answer']),
                title="[bold green]Answer[/bold green]",
                border_style="green"
            ))

            if result['sources']:
                console.print(f"\n[dim]Sources: {len(result['sources'])} documents[/dim]")

        rag.close()

    except KeyboardInterrupt:
        console.print("\n\n[bold yellow]Interrupted by user[/bold yellow]")
        raise typer.Exit(code=0)
    except Exception as e:
        console.print(f"[bold red]✗ Error: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def stats():
    """Show system statistics"""
    try:
        rag = RAGEngine()
        rag.initialize()

        stats = rag.get_statistics()

        console.print("\n[bold cyan]Aerospace RAG System Statistics[/bold cyan]\n")

        # Overall stats
        table = Table(show_header=False, box=None)
        table.add_column("Metric", style="cyan")
        table.add_column("Value", style="green")

        table.add_row("Total Documents", str(stats['total_documents']))
        table.add_row("Configured Courses", str(stats['configured_courses']))
        table.add_row("Indexed Courses", str(len(stats['courses'])))

        console.print(table)

        # Course-wise stats
        if stats['courses']:
            console.print("\n[bold cyan]Indexed Courses:[/bold cyan]\n")

            courses_table = Table(show_header=True, header_style="bold magenta")
            courses_table.add_column("Code", style="cyan")
            courses_table.add_column("Name", style="yellow")
            courses_table.add_column("Documents", style="green", justify="right")

            for course in stats['courses']:
                courses_table.add_row(
                    course['course_code'],
                    course['course_name'],
                    str(course['document_count'])
                )

            console.print(courses_table)

        console.print()
        rag.close()

    except Exception as e:
        console.print(f"[bold red]✗ Error: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def courses():
    """List all configured courses"""
    try:
        config = get_config()
        courses = config.courses

        console.print("\n[bold cyan]MIT OCW Aerospace Courses[/bold cyan]\n")

        table = Table(show_header=True, header_style="bold magenta")
        table.add_column("Course Code", style="cyan", width=12)
        table.add_column("Course Name", style="yellow")

        for code, name in sorted(courses.items()):
            table.add_row(code, name)

        console.print(table)
        console.print()

    except Exception as e:
        console.print(f"[bold red]✗ Error: {e}[/bold red]")
        raise typer.Exit(code=1)


@app.command()
def test():
    """Test system connectivity"""
    try:
        console.print("\n[bold cyan]Testing Aerospace RAG System...[/bold cyan]\n")

        from aerospace_rag.core.ollama_client import OllamaClient
        from aerospace_rag.core.database import DatabaseManager

        # Test Ollama
        console.print("[yellow]Testing Ollama connection...[/yellow]")
        ollama_client = OllamaClient()

        if ollama_client.check_connection():
            console.print("[green]✓ Ollama is running[/green]")

            if ollama_client.check_model_available():
                console.print(f"[green]✓ Model {ollama_client.model} is available[/green]")
            else:
                console.print(f"[red]✗ Model {ollama_client.model} not found[/red]")
        else:
            console.print("[red]✗ Ollama is not accessible[/red]")

        # Test PostgreSQL
        console.print("\n[yellow]Testing PostgreSQL connection...[/yellow]")
        db = DatabaseManager()

        try:
            db.connect()
            console.print("[green]✓ PostgreSQL is accessible[/green]")

            doc_count = db.get_document_count()
            console.print(f"[green]✓ Database has {doc_count} documents[/green]")

            db.disconnect()
        except Exception as e:
            console.print(f"[red]✗ PostgreSQL connection failed: {e}[/red]")

        console.print("\n[bold green]System test completed![/bold green]\n")

    except Exception as e:
        console.print(f"[bold red]✗ Test failed: {e}[/bold red]")
        raise typer.Exit(code=1)


def main():
    """Main entry point"""
    app()


if __name__ == "__main__":
    main()
