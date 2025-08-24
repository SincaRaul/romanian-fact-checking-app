import google.generativeai as genai
import json
from typing import Dict, Any
from app.settings import settings

class GeminiService:
    def __init__(self):
        # Configure Gemini API
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def categorize_fact_check(self, title: str, summary: str = None) -> Dict[str, Any]:
        """
        Categorize a fact-check using Gemini AI
        Returns: {"category": "football", "confidence": 0.85, "explanation": "..."}
        """
        
        # Prepare the prompt for categorization
        text_to_analyze = f"Titlu: {title}"
        if summary:
            text_to_analyze += f"\nRezumat: {summary}"
        
        prompt = f"""
Ești un expert în categorizarea știrilor românești. Analizează următorul fact-check și determină categoria cea mai potrivită.

CATEGORII DISPONIBILE:
- football: Fotbal, echipe, jucători, campionate
- politics_internal: Politică românească, guvern, parlament, alegeri locale
- politics_external: Relații externe, UE, NATO, războaie, diplomație
- bills: Facturi, utilități, energie, gaze, curent electric, apă
- health: Sănătate, medicină, spitale, vaccinuri, tratamente
- technology: Tehnologie, IT, aplicații, internet, gadget-uri
- environment: Mediu, poluare, schimbări climatice, natură
- economy: Economie, inflație, salarii, prețuri, business
- other: Orice altceva care nu se încadrează în categoriile de mai sus

TEXT DE ANALIZAT:
{text_to_analyze}

Răspunde DOAR cu un JSON în această formă:
{{
    "category": "categoria_detectata",
    "confidence": 0.95,
    "explanation": "Explicație scurtă de ce această categorie"
}}
"""

        try:
            response = self.model.generate_content(prompt)
            result_text = response.text.strip()
            
            # Try to parse JSON response
            if result_text.startswith('```json'):
                result_text = result_text.replace('```json', '').replace('```', '').strip()
            
            result = json.loads(result_text)
            
            # Validate the response
            valid_categories = [
                "football", "politics_internal", "politics_external", 
                "bills", "health", "technology", "environment", 
                "economy", "other"
            ]
            
            if result.get("category") not in valid_categories:
                result["category"] = "other"
            
            # Ensure confidence is between 0 and 1
            confidence = result.get("confidence", 0.5)
            if confidence > 1:
                confidence = confidence / 100
            result["confidence"] = max(0.0, min(1.0, confidence))
            
            return result
            
        except Exception as e:
            # Fallback to "other" category if AI fails
            return {
                "category": "other",
                "confidence": 0.1,
                "explanation": f"Eroare la categorizare automată: {str(e)}"
            }

    async def generate_fact_check(self, claim: str) -> Dict[str, Any]:
        """
        Generate a complete fact-check using Gemini AI
        Returns: {"verdict": "true", "confidence": 85, "summary": "...", "category": "..."}
        """
        
        prompt = f"""
Ești un fact-checker expert român. Analizează următoarea afirmație și oferă o verificare completă.

AFIRMAȚIA DE VERIFICAT:
{claim}

Răspunde cu un JSON în această formă:
{{
    "verdict": "true/false/mixed/unclear",
    "confidence": 85,
    "summary": "Explicație detaliată cu surse și dovezi",
    "category": "categoria_corespunzatoare",
    "sources": ["sursă1", "sursă2"]
}}

INSTRUCȚIUNI:
1. verdict poate fi: "true" (adevărat), "false" (fals), "mixed" (parțial adevărat), "unclear" (insuficiente dovezi)
2. confidence este între 0-100
3. summary să fie detaliat și obiectiv
4. category din lista: football, politics_internal, politics_external, bills, health, technology, environment, economy, other
5. sources să fie surse reale și verificabile
"""

        try:
            response = self.model.generate_content(prompt)
            result_text = response.text.strip()
            
            if result_text.startswith('```json'):
                result_text = result_text.replace('```json', '').replace('```', '').strip()
            
            result = json.loads(result_text)
            
            # Validate verdict
            valid_verdicts = ["true", "false", "mixed", "unclear"]
            if result.get("verdict") not in valid_verdicts:
                result["verdict"] = "unclear"
            
            # Validate category
            valid_categories = [
                "football", "politics_internal", "politics_external", 
                "bills", "health", "technology", "environment", 
                "economy", "other"
            ]
            if result.get("category") not in valid_categories:
                result["category"] = "other"
            
            # Ensure confidence is valid
            confidence = result.get("confidence", 50)
            result["confidence"] = max(0, min(100, int(confidence)))
            
            return result
            
        except Exception as e:
            return {
                "verdict": "unclear",
                "confidence": 10,
                "summary": f"Nu am putut verifica această afirmație din cauza unei erori: {str(e)}",
                "category": "other",
                "sources": []
            }

# Singleton instance
gemini_service = GeminiService()
