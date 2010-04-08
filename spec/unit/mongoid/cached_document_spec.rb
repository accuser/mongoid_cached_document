require 'spec_helper'

describe Mongoid::CachedDocument do
  class Document
    include Mongoid::Document
    
    field :cachable_document, :type => Mongoid::CachedDocument
  end

  class CachableDocument
    include Mongoid::Document
    
    field :title
    field :body
  end
    
  describe "#set" do
    describe "with a document that supports caching" do
      before :each do
        @cachable_document = mock(CachableDocument)
        
        @cachable_document.stub(:id).and_return 42
        @cachable_document.stub(:class).and_return CachableDocument
        @cachable_document.stub(:cachable_attributes).and_return({ '_type' => 'CachableDocument', '_id' => 42, 'title' => 'Title' })
      end

      it "prepares a hash of cachable attributes" do
        Mongoid::CachedDocument.set(@cachable_document).should == { '_type' => 'CachableDocument', '_id' => 42, 'title' => 'Title' }
      end
    end
    
    describe "with a document that doesn't support caching" do
      before :each do
        @cachable_document = mock(CachableDocument)
        
        @cachable_document.stub(:id).and_return 42
        @cachable_document.stub(:class).and_return CachableDocument
      end

      it "prepares a hash of cachable attributes" do
        Mongoid::CachedDocument.set(@cachable_document).should == { '_type' => 'CachableDocument', '_id' => 42 }
      end
    end
  end
  
  describe "#get" do
    before :each do
      @cached_document = Mongoid::CachedDocument.get('_type' => 'CachableDocument', '_id' => 42, 'title' => 'Title')
    end
    
    it "instantiates a new instance of CachedDocument from the supplied hash of attributes" do
      @cached_document._type.should == 'CachableDocument'
      @cached_document._id.should be 42
      @cached_document.title == 'Title'
    end
  end
  
  describe "tesing for equality" do
    before :each do
      @cachable_document = mock(CachableDocument)
      
      @cachable_document.stub(:id).and_return 42
      @cachable_document.stub(:class).and_return CachableDocument
      
      @cached_document = Mongoid::CachedDocument.get('_type' => 'CachableDocument', '_id' => 42)
    end
        
    it "#== delegates to the document" do
      CachableDocument.should_receive(:find).with(42).and_return(@cachable_document)    
      @cached_document == @cachable_document
    end

    it "#eql? delegates to the document" do
      CachableDocument.should_receive(:find).with(42).and_return(@cachable_document)    
      @cached_document.eql? @cachable_document
    end

    it "#equal? delegates to the document" do
      CachableDocument.should_receive(:find).with(42).and_return(@cachable_document)    
      @cached_document.equal? @cachable_document
    end
  end
end
