#include <iostream>
#include <fstream>
#include <sstream>
#include <iterator>

#include "driver.h"

extern FILE *yyin;
extern void *yy_scan_string(const char *yy_str, yyscan_t yyscanner);
extern void yyset_in(FILE *_in_str, yyscan_t yyscanner);
extern int yylex_init(yyscan_t *scanner);
extern int yylex_destroy (yyscan_t yyscanner);

namespace bpftrace {

Driver::Driver()
{
  yylex_init(&scanner_);
  parser_ = std::make_unique<Parser>(*this, scanner_);
}

Driver::~Driver()
{
  yylex_destroy(scanner_);
}

int Driver::parse_stdin()
{
  return parser_->parse();
}

int Driver::parse_str(const std::string &script)
{
  yy_scan_string(insert_semicolon(script).c_str(), scanner_);
  int result = parser_->parse();
  return result;
}

int Driver::parse_file(const std::string &f)
{
  std::ifstream file(f.c_str());

  if (!file.is_open()) {
    std::cerr << "Error: Could not open file '" << f << "'" << std::endl;
    return -1;
  }

	std::stringstream buffer;
	buffer << file.rdbuf();
  std::string input = buffer.str();
  file.close();

  input = insert_semicolon(input);

  yy_scan_string(input.c_str(), scanner_);

  int result = parser_->parse();

  return result;
}

void Driver::error(const location &l, const std::string &m)
{
  std::cerr << l << ": " << m << std::endl;
}

void Driver::error(const std::string &m)
{
  std::cerr << m << std::endl;
}

std::string Driver::replace_text(std::string input, std::regex &pattern, const char *replace)
{
  std::smatch match_result;

  unsigned max_iterations = 10000;

  while (std::regex_search(input, match_result, pattern) && max_iterations > 0)
  {
    for (unsigned i=0; i<match_result.size(); i++)
    {

      std::string data = match_result[i];
      int pos = data.size() + match_result.position(i) - 1;
      input.replace(pos - 1, 1, replace);
    }

    max_iterations--;
  }

  return input;
}

std::string Driver::insert_semicolon(std::string input)
{
  std::regex pattern_if ("if.*\\n*\\t*\\s*.*\\n*.*\\}[^\\;](?!else)");
  input = replace_text(input, pattern_if, "};");

  std::regex pattern_else ("else.*\\n*\\t*\\s*.*\\n*.*\\}[^\\;]");
  input = replace_text(input, pattern_else, "};");

  return input;
}

} // namespace bpftrace
