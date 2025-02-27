// A basic test to ensure the Jasmine testing framework is working correctly
describe("Basic test suite", function() {
  it("successfully runs a basic test", function() {
    expect(true).toBe(true);
  });
  
  it("can do basic math", function() {
    expect(1 + 1).toEqual(2);
    expect(5 * 5).toEqual(25);
  });
  
  it("can compare strings", function() {
    expect("hello").toEqual("hello");
    expect("hello").not.toEqual("world");
  });
});