# MiniSQL - SELECT Parser using Flex & Bison

## 📋 Project Overview

**MiniSQL** is a compact SQL parser that parses and validates `SELECT-FROM-WHERE` queries using **Flex** (lexical analyzer) and **Bison** (parser generator). This educational project demonstrates the implementation of a lexical analyzer and syntax parser for a simplified SQL dialect.

The parser accepts SQL queries in the form:
```sql
SELECT <columns> FROM <table> [WHERE <conditions>];
```

It validates the syntax, extracts query components, and displays the parsed results in a user-friendly format.

---

## 🎯 Key Features

✅ **Lexical Analysis** - Tokenizes SQL keywords, identifiers, operators, and delimiters  
✅ **Syntax Parsing** - Validates query structure using context-free grammar  
✅ **Condition Support** - Handles WHERE clauses with logical operators (AND, OR) and comparison operators  
✅ **Column Selection** - Supports wildcard (*) and explicit column lists  
✅ **Error Reporting** - Provides clear syntax error messages  
✅ **Memory Safe** - Proper memory allocation and deallocation  

---

## 📁 Project Structure

### Source Files

| File | Purpose | Language | Lines |
|------|---------|----------|-------|
| `minisql.l` | Lexical analyzer specification | Lex/Flex | 54 |
| `minisql.y` | Grammar and parser specification | Yacc/Bison | 179 |
| `lex.yy.c` | Generated lexical analyzer code | C | 41,196 |
| `minisql.tab.c` | Generated parser code | C | 49,515 |
| `minisql.tab.h` | Generated parser header | C | 2,543 |
| `a.exe` | Compiled executable | Binary | - |

### Additional Files

- **README.md** - Project documentation
- **LICENSE** - MIT License
- **CSE313 MiniSQL - SELECT -parser using Flex Bison Project Report.pdf** - Detailed project report

---

## 🔧 Architecture

### 1. **Lexical Analysis (minisql.l)**

The lexer (Flex specification) performs the following:

- **Keyword Recognition**: Recognizes SQL keywords
  - `SELECT`, `FROM`, `WHERE`, `AND`, `OR`
  
- **Token Classification**:
  - **Keywords**: SELECT, FROM, WHERE, AND, OR
  - **Operators**: = (EQ), <> (NE), >= (GE), <= (LE), > (GT), < (LT)
  - **Symbols**: * (STAR), , (COMMA), ; (SEMI), ( (LPAREN), ) (RPAREN)
  - **Identifiers**: Column and table names matching pattern `[a-zA-Z_][a-zA-Z0-9_]*`
  - **Numbers**: Integer values

- **Whitespace Handling**: Ignores spaces, tabs, newlines, and carriage returns

- **Token Attributes**:
  - `ID` tokens store string values (identifiers)
  - `NUMBER` tokens store integer values
  - Keyword tokens have no semantic value

```lex
/* Pattern Examples */
{digit}+        → NUMBER token with integer value
{id}            → ID token with string value
"SELECT"        → SELECT keyword token
```

### 2. **Syntax Parsing (minisql.y)**

The parser (Bison specification) defines the grammar for SELECT queries:

#### Grammar Rules:

```
query → SELECT select_list FROM ID opt_where SEMI
      
select_list → STAR
            | column_list

column_list → ID
            | column_list COMMA ID

opt_where → ε (empty)
          | WHERE condition

condition → expr
          | condition AND condition
          | condition OR condition
          | LPAREN condition RPAREN

expr → ID comp_op value

comp_op → EQ | LT | GT | LE | GE | NE

value → NUMBER | ID
```

#### Operator Precedence:

```
%left OR          /* Lower precedence */
%left AND
%nonassoc EQ LT GT LE GE NE  /* Higher precedence */
```

This ensures proper parsing of complex conditions like:
```sql
age >= 18 AND marks > 50 OR grade = 'A'
```

#### Key Parsing Actions:

1. **Query Processing**: Extracts table name, column list, and WHERE clause
2. **Column Selection**: Handles wildcard (*) and comma-separated column lists
3. **WHERE Clause Building**: Constructs condition strings with proper operators and grouping
4. **Memory Management**: Allocates and deallocates strings for parsed components
5. **Output**: Displays parsed query components in formatted output

### 3. **Semantic Analysis & Output**

The parser performs semantic actions during syntax analysis:

- **Table Name Extraction**: Stored in `current_table` buffer
- **Column List Construction**: Built incrementally in `selected_columns` buffer
- **Condition String Formation**: Created in `where_clause` buffer using malloc/sprintf

**Output Format**:
```
✅ Valid SQL query.
   Table   : <table_name>
   Columns : <column_list>
   WHERE   : <condition_string>
```

---

## 📚 Data Structures & Buffers

```c
/* Global buffers for storing parsed information */
char current_table[100];      /* Stores the table name */
char selected_columns[500];   /* Stores selected columns (comma-separated) */
char where_clause[500];       /* Stores WHERE condition as formatted string */
```

### Semantic Values

```c
%union {
    int ival;      /* Integer values (for numbers) */
    char *sval;    /* String values (for identifiers, operators) */
}
```

---

## 🚀 Supported SQL Syntax

### Valid Query Examples

```sql
/* Select all columns */
SELECT * FROM students;

/* Select specific columns */
SELECT name, age FROM students;

/* Simple WHERE clause */
SELECT * FROM teachers WHERE salary >= 50000;

/* Complex conditions with AND */
SELECT name, age FROM students WHERE age >= 18 AND grade = 'A';

/* Grouped conditions with OR */
SELECT * FROM products WHERE price > 100 OR category = 'electronics';

/* Nested conditions with parentheses */
SELECT * FROM orders WHERE (status = 'pending' AND amount > 1000) OR (priority = 'urgent');
```

### Supported Operators

| Operator | Symbol | Usage |
|----------|--------|-------|
| Equal | `=` | `age = 18` |
| Not Equal | `<>` | `status <> 'inactive'` |
| Greater Than | `>` | `salary > 50000` |
| Less Than | `<` | `count < 10` |
| Greater Equal | `>=` | `age >= 18` |
| Less Equal | `<=` | `price <= 100` |
| Logical AND | `AND` | `age >= 18 AND marks > 50` |
| Logical OR | `OR` | `grade = 'A' OR grade = 'B'` |

---

## 🛠️ Compilation & Execution

### Prerequisites

- **Flex** (lexical analyzer generator)
- **Bison** (parser generator)
- **GCC** (C compiler)

### Build Steps

```bash
# Step 1: Generate lexical analyzer from .l file
flex minisql.l

# Step 2: Generate parser from .y file
bison -d minisql.y

# Step 3: Compile generated code with C compiler
gcc -o parser lex.yy.c minisql.tab.c -lfl

# Alternative: Using shorter names
bison minisql.y
flex minisql.l
gcc lex.yy.c minisql.tab.c -o a.exe
```

### Running the Parser

```bash
./parser
# or on Windows
./a.exe
```

The program will prompt:
```
MiniSQL - SELECT-FROM-WHERE Parser
Example queries:
  SELECT name, age FROM students WHERE age >= 18;
  SELECT * FROM teachers;

Enter your SQL query:
```

Then enter your SQL query and press Enter.

### Example Execution

```
Enter your SQL query:
SELECT name, age FROM students WHERE age >= 18;

✅ Valid SQL query.
   Table   : students
   Columns : name, age
   WHERE   : age >= 18
```

---

## 📊 Language Composition

- **C**: 94.8% (Core implementation and generated parser code)
- **Yacc/Bison**: 4.0% (Grammar and parser specification)
- **Lex/Flex**: 1.2% (Lexical analyzer specification)

---

## ⚙️ Technical Implementation Details

### Token Generation Flow

```
Input SQL String
        ↓
    [Flex Lexer]  (minisql.l)
        ↓
   Token Stream (ID, SELECT, FROM, WHERE, etc.)
        ↓
    [Bison Parser] (minisql.y)
        ↓
   Parsed Components (table, columns, conditions)
        ↓
    Validation & Output
```

### Memory Management

- **Dynamic Allocation**: Used for string buffers in condition building
  - `malloc()` allocates memory for formatted condition strings
  - `free()` deallocates after copying to buffers

- **Fixed Buffers**: Used for storing final results
  - `current_table[100]`
  - `selected_columns[500]`
  - `where_clause[500]`

- **String Functions**: Safe string operations with size limits
  - `strncpy()` - bounded copying
  - `strcat()` - concatenation

---

## 🔍 Error Handling

### Syntax Errors

If the input doesn't match the grammar rules, the parser generates an error:

```bash
Enter your SQL query:
SELECT name FROM students WHERE;

❌ Syntax error: unexpected WHERE
```

### Lexical Errors

Unknown characters trigger lexical errors:

```bash
Enter your SQL query:
SELECT name FROM students @;

Unknown character: @
```

---

## 📖 Grammar Specification Summary

### Complete EBNF Grammar

```ebnf
Query      ::= SELECT SelectList FROM Identifier OptWhere SEMI
SelectList ::= STAR | ColumnList
ColumnList ::= Identifier | ColumnList COMMA Identifier
OptWhere   ::= ε | WHERE Condition
Condition  ::= Expr 
            | Condition AND Condition
            | Condition OR Condition
            | LPAREN Condition RPAREN
Expr       ::= Identifier CompOp Value
CompOp     ::= EQ | LT | GT | LE | GE | NE
Value      ::= NUMBER | Identifier
```

### Conflict Resolution

- **Shift-Reduce Conflicts**: None (clean grammar)
- **Reduce-Reduce Conflicts**: None (unambiguous)
- **Operator Precedence**: OR < AND < Comparisons

---

## 🎓 Educational Value

This project demonstrates:

1. **Lexical Analysis Concepts**
   - Regular expressions for token patterns
   - Token classification and attributes
   - Whitespace and comment handling

2. **Syntax Analysis Concepts**
   - Context-free grammars (CFG)
   - Shift-reduce parsing
   - Grammar rules and productions

3. **Compiler Design Principles**
   - Multi-phase compilation (lex → parse → analyze)
   - Semantic actions during parsing
   - Error recovery and reporting

4. **Software Engineering**
   - Tool usage (Flex, Bison)
   - Code generation
   - Integration of generated code

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Mehrab Hossen**  
Created as a CSE313 (Compiler Design) course project

---

## 📚 References & Resources

- **Flex Documentation**: https://westes.github.io/flex/manual/
- **Bison Documentation**: https://www.gnu.org/software/bison/manual/
- **SQL Syntax Reference**: https://en.wikipedia.org/wiki/SQL_syntax
- **Compiler Design (Dragon Book)**: Aho, Lam, Sethi, Ullman

---

## 🔗 Project Report

For detailed analysis, design decisions, and implementation details, refer to:
- **CSE313 MiniSQL - SELECT -parser using Flex Bison Project Report.pdf**

---

## 📞 Support & Questions

For issues, questions, or improvements, feel free to open an issue or contact the author.

---

**Last Updated**: October 2026  
**Status**: Completed ✅
