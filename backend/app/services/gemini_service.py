import json
import asyncio
import logging
from typing import Dict, Any
from google import genai
from google.genai import types
from app.settings import settings

logger = logging.getLogger(__name__)

class GeminiService:
    def __init__(self):
        # Configure the new Gemini client with API key
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        
        # Define the grounding tool for Google Search
        self.grounding_tool = types.Tool(google_search=types.GoogleSearch())
        
        # Configure generation settings with grounding and timeouts
        self.config = types.GenerateContentConfig(
            tools=[self.grounding_tool],
            # Add timeout and other safety settings
            safety_settings=[
                types.SafetySetting(
                    category=types.HarmCategory.HARM_CATEGORY_HARASSMENT,
                    threshold=types.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
                ),
                types.SafetySetting(
                    category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                    threshold=types.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
                )
            ]
        )
        
        # Timeout settings (in seconds) - optimized for Gemini 2.5 Pro
        self.request_timeout = 90  # Maximum 90 seconds for each request (Pro models can be slower)
        self.search_timeout = 45   # Maximum 45 seconds for search grounding

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
            # Use the client with timeout for categorization
            response = await asyncio.wait_for(
                asyncio.to_thread(
                    self.client.models.generate_content,
                    model="gemini-2.5-pro",
                    contents=prompt,
                    config=types.GenerateContentConfig()  # No grounding needed for categorization
                ),
                timeout=self.search_timeout  # Shorter timeout for categorization
            )
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
        Generate a complete fact-check using  Google Search Grounding
        Returns: {"verdict": "true", "confidence": 85, "summary": "...", "category": "...", "sources": [...]}
        """
        
        prompt = f"""
Ești un fact-checker expert român. Verifică următoarea afirmație și oferă un răspuns detaliat bazat pe informații actuale de pe web.

AFIRMAȚIA DE VERIFICAT:
{claim}

INSTRUCȚIUNI CRITICE PENTRU FORMATARE:
1. Caută informații actuale și verificabile pe web
2. Analizează sursele găsite pentru acuratețe
3. Oferă un verdict clar bazat pe evidențe
4. IMPORTANT: Scrie summary-ul ca un TEXT COMPLET FLUID, fără referințe numerice
5. NU folosi NICIODATĂ [1], [2], [3], [4], [5] sau alte referințe în paranteză pătrate
6. Integrează informațiile natural în propoziții complete
7. NU inventa URL-uri - folosește doar URL-urile reale găsite prin căutare

EXEMPLE DE SCRIERE CORECTĂ:
✅ CORECT: "Conform surselor oficiale, România a înregistrat o creștere economică în primul trimestru. Guvernul a confirmat aceste cifre prin comunicate de presă."
❌ GREȘIT: "România a înregistrat o creștere economică [1]. Guvernul a confirmat datele [2]."

✅ CORECT: "Există mai multe instrumente de testare software cu nume similare, inclusiv Test::Simple pentru Perl și Simple Test pentru Salesforce."
❌ GREȘIT: "Există Test::Simple [1] și Simple Test [2]."

Răspunde DOAR cu un JSON în această formă EXACTĂ:
{{
    "verdict": "true/false/mixed/unclear",
    "confidence": 85,
    "summary": "Explicație detaliată scrisă complet fluid, fără referințe numerice, integrând natural informațiile din surse",
    "category": "football/politics_internal/politics_external/health/economy/technology/environment/bills/other",
    "sources": [
        "Titlu sursă 1 - https://site1.com",
        "Titlu sursă 2 - https://site2.com"
    ]
}}

VERDICTS - ALEGE CU ATENȚIE:
- true: afirmația este COMPLET ADEVĂRATĂ conform tuturor surselor verificate
- false: afirmația este COMPLET FALSĂ conform tuturor surselor verificate
- mixed: afirmația este PARȚIAL ADEVĂRATĂ (unele părți corecte, altele false)
- unclear: informații contradictorii sau insuficiente pentru un verdict clar

CONFIDENCE: 0-100 (cât de sigur ești bazat pe sursele găsite)
SOURCES: Array cu 2-4 surse REALE în format "Titlu - URL real găsit pe web"

ATENȚIE: Summary-ul trebuie să fie un text COMPLET FLUID fără referințe numerice!
"""

        try:
            # Try multiple models with retry system
            response = await self._generate_with_retry(prompt)
            if not response:
                raise Exception("All models failed to respond")
            
            # Extract the main result
            result_text = response.text.strip()
            
            # Clean JSON formatting
            if result_text.startswith('```json'):
                result_text = result_text.replace('```json', '').replace('```', '').strip()
            
            result = json.loads(result_text)
            
            # Debug: dump raw response to see where sources are
            self._dump_response_debug(response)
            
            # Extract real sources using comprehensive method
            real_sources = self._extract_sources(response)
            logger.info(f"Total real sources extracted: {len(real_sources)}")
            
            # Add real sources to result - prioritize real sources over AI-provided ones
            if real_sources:
                result["sources"] = real_sources
                logger.info("Using real sources from grounding")
            else:
                logger.warning("No grounding sources found for claim: %s", claim[:100])
                # Also check if sources were provided in the AI response itself
                ai_sources = result.get("sources", [])
                if ai_sources and isinstance(ai_sources, list) and len(ai_sources) > 0:
                    # Use AI-provided sources if they look valid
                    valid_ai_sources = [s for s in ai_sources if s and isinstance(s, str) and len(s.strip()) > 0]
                    if valid_ai_sources:
                        result["sources"] = valid_ai_sources
                        logger.info(f"Using AI-provided sources: {valid_ai_sources}")
                    else:
                        result["sources"] = ["Nu s-au găsit surse verificabile pentru această afirmație"]
                else:
                    result["sources"] = ["Nu s-au găsit surse verificabile pentru această afirmație"]
            
            # Validate result structure
            result = self._validate_fact_check_result(result, claim)
            
            return result
            
        except asyncio.TimeoutError:
            print(f"Timeout error in Gemini fact-check generation after {self.request_timeout}s")
            # Return fallback result for timeout
            return {
                "verdict": "unclear",
                "confidence": 15,
                "summary": f"Nu am putut verifica această afirmație în timp util (timeout după {self.request_timeout} secunde). Verificarea automată a durat prea mult.",
                "category": "other",
                "sources": ["Timeout în verificarea automată"]
            }
        except Exception as e:
            error_msg = str(e)
            logger.error(f"Error in Gemini fact-check generation: {error_msg}")
            
            # Provide user-friendly error messages
            if "503" in error_msg or "overloaded" in error_msg.lower() or "UNAVAILABLE" in error_msg:
                return {
                    "verdict": "unclear",
                    "confidence": 10,
                    "summary": "Serviciul de verificare AI este temporar supraîncărcat. Toate modelele disponibile sunt ocupate în acest moment. Vă rugăm să încercați din nou în câteva minute.",
                    "category": "other",
                    "sources": ["Serviciu AI temporar indisponibil"]
                }
            elif "timeout" in error_msg.lower():
                return {
                    "verdict": "unclear",
                    "confidence": 15,
                    "summary": "Verificarea a durat prea mult timp și a fost întreruptă. Acest lucru se poate întâmpla pentru întrebări foarte complexe sau când serviciul este lent.",
                    "category": "other",
                    "sources": ["Timeout în verificarea automată"]
                }
            else:
                return {
                    "verdict": "unclear",
                    "confidence": 10,
                    "summary": f"Nu am putut verifica această afirmație din cauza unei erori tehnice: {error_msg[:100]}...",
                    "category": "other",
                    "sources": ["Eroare tehnică în verificarea automată"]
                }

    async def _generate_with_retry(self, prompt: str):
        """Try models in exact order: 2.5 Pro -> 2.5 Flash -> 1.5 Pro -> 1.5 Flash"""
        models_to_try = [
            ("gemini-2.5-pro", self.request_timeout),      # First choice
            ("gemini-2.5-flash", 30),                      # Fast backup
            ("gemini-1.5-pro", 60),                        # Stable option
            ("gemini-1.5-flash", 25)                       # Last resort
        ]
        
        last_error = None
        logger.info(f"Starting model retry sequence for {len(models_to_try)} models")
        
        for i, (model_name, timeout) in enumerate(models_to_try):
            try:
                logger.info(f"Attempt {i+1}/{len(models_to_try)}: Trying model {model_name} with {timeout}s timeout")
                response = await asyncio.wait_for(
                    asyncio.to_thread(
                        self.client.models.generate_content,
                        model=model_name,
                        contents=prompt,
                        config=self.config
                    ),
                    timeout=timeout
                )
                logger.info(f"✅ SUCCESS with model: {model_name}")
                return response
                
            except Exception as e:
                error_msg = str(e)
                logger.warning(f"❌ Model {model_name} failed: {error_msg[:200]}")
                last_error = e
                
                # Log what kind of error for debugging
                if "503" in error_msg or "overloaded" in error_msg.lower() or "UNAVAILABLE" in error_msg:
                    logger.info(f"   Reason: Model overloaded, trying next model...")
                elif "timeout" in error_msg.lower():
                    logger.info(f"   Reason: Timeout after {timeout}s, trying next model...")
                else:
                    logger.info(f"   Reason: Other error, trying next model...")
                    
                # Continue to next model
                continue
        
        # If all models failed, return None instead of raising
        logger.error(f"🚫 ALL {len(models_to_try)} MODELS FAILED. Last error: {str(last_error)}")
        return None

    def _dump_response_debug(self, response):
        """Debug function to log raw response structure"""
        try:
            # Best effort: convert to plain dict for safe logging
            if hasattr(response, "to_dict"):
                d = response.to_dict()
            else:
                # Fallback: use __dict__ recursively
                import json
                d = json.loads(json.dumps(response, default=lambda o: getattr(o, '__dict__', str(o))))
            logger.debug("GEMINI RAW RESPONSE: %s", json.dumps(d, ensure_ascii=False)[:10000])
        except Exception as e:
            logger.warning("Could not dump response: %s", e)

    def _extract_sources(self, response) -> list:
        """Extract sources from groundingMetadata.groundingChunks as per Gemini API docs"""
        out = []

        # Extract from groundingMetadata.groundingChunks[*].web.{uri, title}
        try:
            # Navigate: response.candidates[0].grounding_metadata.grounding_chunks
            cands = getattr(response, "candidates", []) or []
            if cands and len(cands) > 0:
                grounding_metadata = getattr(cands[0], "grounding_metadata", None)
                if grounding_metadata:
                    grounding_chunks = getattr(grounding_metadata, "grounding_chunks", None)
                    if grounding_chunks:
                        logger.info(f"Found {len(grounding_chunks)} grounding chunks")
                        for i, chunk in enumerate(grounding_chunks):
                            web = getattr(chunk, "web", None)
                            if web:
                                uri = getattr(web, "uri", "") or ""
                                title = getattr(web, "title", "Sursă web") or "Sursă web"
                                
                                logger.debug(f"Chunk {i}: title='{title}', uri='{uri}'")
                                
                                if uri.startswith(("http://", "https://")):
                                    # Clean title - remove problematic characters  
                                    title = title.replace('[', '').replace(']', '').replace('|', '-')
                                    if len(title) > 80:
                                        title = title[:77] + "..."
                                    out.append(f"{title} - {uri}")
                    else:
                        logger.info("No grounding_chunks found in grounding_metadata")
                else:
                    logger.info("No grounding_metadata found in first candidate")
            else:
                logger.info("No candidates found in response")
        except Exception as e:
            logger.warning("Error extracting from grounding_chunks: %s", e)

        # Deduplicate sources in order
        seen = set()
        unique_sources = []
        for source in out:
            if source not in seen:
                seen.add(source)
                unique_sources.append(source)
        
        logger.info(f"Extracted {len(unique_sources)} unique sources from grounding metadata")
        return unique_sources[:4]  # Limit to 4 sources max

    def _validate_fact_check_result(self, result: Dict[str, Any], claim: str) -> Dict[str, Any]:
        """Validate and clean the fact-check result"""
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
        
        # Ensure sources exist
        if not result.get("sources"):
            result["sources"] = ["Nu s-au găsit surse verificabile pentru această verificare"]
        
        return result

# Singleton instance
gemini_service = GeminiService()
