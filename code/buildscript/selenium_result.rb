require "builder"
require "hpricot"

require "test_case_result"

class SeleniumResult
  def initialize(req)
    @req = req
    @test_cases = parse
  end
  
  def to_xml 
    xml = Builder::XmlMarkup.new(:indent => 1)
    xml.testsuite(
        "tests" => @req.query["numTestPasses"].to_i + @req.query["numTestFailures"].to_i, 
        "errors" => 0,
        "failures" => @req.query["numTestFailures"],
        "time" => @req.query["totalTime"],
        "name" => "SeleniumTestSuite") do 
      @test_cases.each do |result|
        xml << result.to_xml
      end
    end
  end
  
  def to_html
    result = @req.query["suite"]
     (1..number_of_tests()).each do |i|
      result += @req.query["testTable.#{i}"]
    end
    return result
  end
  
  def success?()
    @req.query["numTestFailures"].to_i == 0
  end
  
  def test_case_name(i)
    doc = Hpricot(@req.query["suite"])
    name = ""
    doc.search("//a")[i].traverse_text { |t| name += t.to_s }
    return name
  end
  
  private 
  def parse
    results = []
    for i in 1..number_of_tests
      results << TestCaseResult.parse_selenium(@req.query["testTable.#{i}"], test_case_name(i - 1))
    end
    return results
  end
  
  def number_of_tests()
    @req.query["numTestPasses"].to_i + @req.query["numTestFailures"].to_i  
  end
end
