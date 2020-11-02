from flask import Flask, render_template, request
import joblib
import numpy as np
import re
#from sklearn.feature_extraction.text import TfidfVectorizer
from tensorflow import keras
import my_tokenizer
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import CountVectorizer

#from keras.models import Model, load_model

app = Flask(__name__)

@app.route('/', methods=['POST','GET'])


# def my_tokenizer(x):
#     return x.split(",")


def main():
    maxlen = 100
    model = keras.models.load_model('pre_trained_glove_model_abilities.h5')
    title_encoder = joblib.load('TitleLabelEncoder.joblib')
    skills_vectorizer = joblib.load('SkillsVectorizer.joblib')
    desc_tokenizer = joblib.load('DescTokenizer.joblib')
    if request.method == 'GET':
        return render_template('index.html')
    if request.method == 'POST':
        description = request.form['description']	
		#corpus = []
        description = re.sub('[^a-zA-Z]', ' ', description)
        description = description.lower()
		#description = description.split()
		#lemmatizer = WordNetLemmatizer()
		#description = [lemmatizer.lemmatize(word) for word in description if not word in set(stopwords.words('english'))]
		#description = ' '.join(description)
		#corpus.append(description)


        desc_enc = desc_tokenizer.texts_to_sequences([description])
        desc_enc = keras.preprocessing.sequence.pad_sequences(desc_enc, maxlen=maxlen)
        answer = model.predict(desc_enc)
        answer = 'Title: ' + title_encoder.inverse_transform(np.argmax(answer[0], axis=-1))[0] + '\n' + \
                 'Skills: ' + ', '.join(skills_vectorizer.inverse_transform(np.argsort(answer[1])[0][:10])[0])
        return answer
		# if answer == '1':
		# 	return "That looks like a positive description"
		# else:
		# 	return "You dont seem to have liked that movie."

if __name__ == "__main__":
    app.run()
