require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  let(:articles) { FactoryGirl.create_list(:article, 4) }
  let(:state) {FactoryGirl.create(:state)}

  describe '#index' do

    before(:each) { get :index }

    it 'assigns all articles to @articles' do
      expect(assigns(:articles)).to match_array articles
    end

    it 'success' do
      expect(response).to be_success
    end
  end

  describe '#show' do
    context 'when requested article exists' do
      let(:article) { articles.first }
      before(:each) { get :show, id: article.id }

      it 'success' do
        expect(response).to be_success
      end

      it 'assigns it to @article' do 
        expect(assigns(:article)).to eq article
      end
    end

    context 'when requested article does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { get :show, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#create' do
    login_user

    context 'when valid' do
      let(:article_attrs) { FactoryGirl.attributes_for(:article) }


      it 'success' do
        post :create, {'article': article_attrs}
        expect(response).to redirect_to(article_path(Article.last))
      end

      it 'saves and assigns new article to @article' do
        post :create, {'article': article_attrs}
        expect(assigns(:article)).to be_a_kind_of(Article)
        expect(assigns(:article)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:article_attrs) { attributes_for(:invalid_article) }

      it 'fails' do
        post :create, {'article': article_attrs}
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    login_user
    let(:article) { create(:article) }

    context 'when valid' do
      let(:new_values) { attributes_for(:article) }

      it 'success' do
        patch :update, ** new_values, id: article.id, article: new_values
        expect(response).to redirect_to(article_path(Article.last))
      end

      it 'saves and assigns article to @article' do
        patch :update, ** new_values, id: article.id, article: new_values
        expect(assigns(:article)).to be_a_kind_of(Article)
        expect(assigns(:article)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:new_values) { attributes_for(:invalid_article) }

      it 'redirects to the edit page' do
        patch :update, id: article.id, article: new_values
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    login_user
    context 'when requested article exists' do
      let(:article) { articles[rand 4] }
      before(:each) { delete :destroy, id: article.id }

      it 'success' do
        expect(response).to redirect_to(root_path)
      end

      it 'removes article form DB' do
        expect(Article.all).not_to include article
        expect { article.reload }.to raise_exception ActiveRecord::RecordNotFound
      end
    end

    context 'when requested article does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { delete :destroy, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
