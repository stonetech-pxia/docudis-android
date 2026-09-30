/// Publicly traded investment products and the indices they follow
/// ("Vanguard Total Stock Market ETF", "iShares Core S&P 500 ETF", "MSCI"):
/// millions of people hold the same fund, so its name says nothing about who
/// holds it, and a statement without them cannot be read. Decided by the
/// user on 2026-09-26, after a photographed portfolio statement lost every
/// fund name. A fund house on its own ("your adviser at Vanguard") is still a
/// company.
final _productMarker = RegExp(
  r'(?<![\p{L}\p{N}])(?:ETFs?|ETP|ETN|UCITS|SICAV|OPCVM|FCP|SPDR|iShares|Xtrackers|Lyxor|'
  r'MSCI|FTSE|STOXX|Stoxx|Nasdaq|NASDAQ|DAX|Nikkei|S&P|Dow Jones|Trust Series|Index Fund|'
  r'CAC 40|IBEX 35|Hang Seng|Russell \d{3,4})(?![\p{L}\p{N}])',
  unicode: true,
);

/// True when [name] names a public investment product or a market index.
bool isPublicProduct(String name) => _productMarker.hasMatch(name);
