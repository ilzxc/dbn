{
  function extractList(list, index) {
      var result = new Array(list.length), i;

      for (i = 0; i < list.length; i++) {
        result[i] = list[i][index];
      }

      return result;
    }
}

Start
  = __ program:Program __ { return program; }

SourceCharacter
  = .

WhiteSpace "whitespace"
  = "\t"
  / "\n"
  / "\r"
  / "\v"
  / "\f"
  / " "

__
  = (WhiteSpace)*

Keyword
  = [A-Z]+ { 
    return text()
  } 

Attribute
  = '@' attrib:[a-z]+ { 
    return text()
  }

Number
  = number:[0-9]+ { 
    return {
      type: 'number',
      value: parseInt(text(), 10)
    };
  }

Word
  = word:[a-z]+ { 
    return {
      type: 'word',
      value: text()
    };
  }

Color
  = '#' [A-Fa-f0-9]+ {
    return {
      type: 'word',
      value: text()
    }
  }

AttrValue
  = Word
  / Number
  / Color

AttrList
  = head:AttrValue tail:(__ AttrValue)*
  {
    return [head].concat(extractList(tail, 1));
  }

SetAttribute 
  = attr:Attribute __ args:(AttrList)
  {
    return {
      attribute: attr,
      args: args
    }
  }

MultiAttrs
  = head:SetAttribute tail:(__ SetAttribute)*
  {
    return [head].concat(extractList(tail, 1));
  }

Statement
  = kw:Keyword __ attrs:(MultiAttrs) {
    return {
      keyword: kw,
      attributes: attrs
    };
  }

SourceElement = Statement // for now this is all we have

SourceElements
  = head:SourceElement tail:(__ SourceElement)* {
    return [head].concat(extractList(tail, 1));
  }

Program
  = body:SourceElements? { 
    return {
      type: "Program",
      body: body !== null ? body : []
    };
  }
